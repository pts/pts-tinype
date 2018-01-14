;
; hh4.nasm
; by pts@fazekas.hu at Sat Jan 13 11:53:58 CET 2018
;
; How to compile hh4.exe:
;
;   $ nasm -f bin -o hh4.exe hh4.nasm
;   $ chmod 755 hh4.exe  # For QEMU Samba server.
;   $ ndisasm -b 32 -e 0x8c -o 0x40008c hh4.exe
;
; hh4.asm was inspired by the 268-byte .exe on
; https://www.codejuggle.dj/creating-the-smallest-possible-windows-executable-using-assembly-language/
; . The fundamental difference is that hh4.exe works on Windows XP ... Windows
; 10, while the program above doesn't work on Windows XP (but works on
; Windows 7).
;
; The generated hh4.exe works on:
;
; * Wine 1.6.2 on Linux.
; * It doesn't work on
;   Windows XP SP3, 32-bit: Microsoft Windows XP [Version 5.1.2600]
;   The application failed to initialize properly (0xc000007b).
;   Click on OK to terminate the application.
; * Windows 7: Microsoft Windows [Version 6.1.7600]
; * ?? Windows 10 64-bit: Microsoft Windows [Version 10.0.16299.192]
;
bits 32
imagebase equ 0x400000
bits 32
org 0  ; Can be anything, this file doesn't depend on it.

_filestart:

IMAGE_DOS_HEADER:  ; Truncated, breaks file(1) etc.
dw 'MZ', 0

IMAGE_NT_HEADERS:
Signature: dw 'PE', 0

IMAGE_FILE_HEADER:
Machine: dw 0x14c  ; IMAGE_FILE_MACHINE_I386
NumberOfSections:
;dw 0
IMAGE_IMPORT_BY_NAME_ExitProcess:
.Hint: dw 0
TimeDateStamp:
;dd 0x00000000
;PointerToSymbolTable: dd 0x00000000
;NumberOfSymbols: dd 0x00000000
;db 'xxxxxxxxxxxx'
.Name: db 'ExitProcess', 0
SizeOfOptionalHeader: dw _datadir_end - _opthd
Characteristics: dw 2
_opthd:
IMAGE_OPTIONAL_HEADER32:
Magic: dw 0x10b  ; IMAGE_NT_OPTIONAL_HDR32_MAGIC
MajorLinkerVersion:
;db 0
;MinorLinkerVersion: db 0
;SizeOfCode: dd 0x00000000
;SizeOfInitializedData: dd 0x00000000
;SizeOfUninitializedData: dd 0x00000000
;db 'xxxxxxxxxxxxxx'
IMAGE_IMPORT_BY_NAME_WriteFile:
.Hint: dw 0
.Name: db 'WriteFile', 0
dw 0 ; Padding, unusued.
AddressOfEntryPoint: dd (_entry - _filestart)
BaseOfCode:
;dd 0x00000000
;BaseOfData: dd (IMAGE_NT_HEADERS - _filestart)  ; Overlaps with: IMAGE_DOS_HEADER.e_lfanew.
;db 'xxxxxxxx'
_KERNEL32_str: db 'kernel32'  ; NUL-terminated below. 'KERNEL32' and 'KERNEL32.dll' also work.
ImageBase: dd imagebase  ; First (LSB) byte is 0, terminates the string above
SectionAlignment: dd 4
FileAlignment: dd 4
MajorOperatingSystemVersion:
;dw 0
;MinorOperatingSystemVersion: dw 0
;MajorImageVersion: dw 0
;MinorImageVersion: dw 0
db 'xxxxxxxx'
MajorSubsystemVersion: dw 4
MinorSubsystemVersion:
;dw 0
;Win32VersionValue: dd 0  ; Nonzero values can break D3D.
db 'xxxxxx'
SizeOfImage: dd (_eof + bss_size - _filestart)  ; Wine rounds it up to a multiple of 0x1000, and loads and maps that much.
SizeOfHeaders: dd 0x2c  ; Must be at least 0x2c on Windows 7, and <= AddressOfEntryPoint on Windows 8.
CheckSum:
;dd 0
db 'xxxx'
Subsystem: dw 3  ; IMAGE_SUBSYSTEM_WINDOWS_CUI; gcc -mconsole
DllCharacteristics: dw 0
SizeOfStackReserve: dd 0x00100000
SizeOfStackCommit: dd 0x00001000
SizeOfHeapReserve: dd 0
SizeOfHeapCommit: dd 0
LoaderFlags: dd 0
NumberOfRvaAndSizes: dd 2

_datadir:
DataDirectory:
IMAGE_DIRECTORY_ENTRY_EXPORT:
.VirtualAddress: dd 0x00000000
.Size: dd 0x00000000
IMAGE_DIRECTORY_ENTRY_IMPORT:
.VirtualAddress: dd (_idescs - _filestart)
.Size: dd 0  ; Ignored.

_datadir_end:
_headers_end:

_entry:
; Arguments pushed in reverse order, popped by the callee.
; WINBASEAPI HANDLE WINAPI GetStdHandle (DWORD nStdHandle);
; HANDLE hfile = GetStdHandle(STD_OUTPUT_HANDLE);
push byte -11                ; STD_OUTPUT_HANDLE
call [imagebase + (__imp__GetStdHandle@4 - _filestart)]
; Arguments pushed in reverse order, popped by the callee.
; WINBASEAPI WINBOOL WINAPI WriteFile (HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPDWORD lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped);
; DWORD bw;
push eax                     ; Value does't matter.
mov ecx, esp
push byte 0                  ; lpOverlapped
push ecx                     ; lpNumberOfBytesWritten = &dw
push byte (_msg_end - _msg)  ; nNumberOfBytesToWrite
push imagebase + (_msg - _filestart)  ; lpBuffer
push eax                     ; hFile = hfile
call [imagebase + (__imp__WriteFile@20 - _filestart)]
;pop eax                     ; This would pop dw. Needed for cleanup.
; Arguments pushed in reverse order, popped by the callee.
; WINBASEAPI DECLSPEC_NORETURN VOID WINAPI ExitProcess(UINT uExitCode);
push byte 0                  ; uExitCode
call [imagebase + (__imp__ExitProcess@4 - _filestart)]

_data:
_msg:
db 'Hello, World!', 13, 10
_msg_end:

; This can be before of after _entry, it doesn't matter.
_idata:  ; Relocations, IMAGE_DIRECTORY_ENTRY_IMPORT data.
_hintnames:
dd (IMAGE_IMPORT_BY_NAME_ExitProcess - _filestart)
dd (IMAGE_IMPORT_BY_NAME_GetStdHandle - _filestart)
dd (IMAGE_IMPORT_BY_NAME_WriteFile - _filestart)
dd 0  ; Marks end-of-list.
_iat:  ; Modified by the PE loader before jumping to _entry.
__imp__ExitProcess@4:  dd (IMAGE_IMPORT_BY_NAME_ExitProcess - _filestart)
__imp__GetStdHandle@4: dd (IMAGE_IMPORT_BY_NAME_GetStdHandle - _filestart)
__imp__WriteFile@20:   dd (IMAGE_IMPORT_BY_NAME_WriteFile - _filestart)
dw 0  ; Marks end-of-list, 2nd half of the dd is the dw below.
IMAGE_IMPORT_BY_NAME_GetStdHandle:
.Hint: dw 0
.Name: db 'GetStdHandle', 0

_idescs:
IMAGE_IMPORT_DESCRIPTOR__0:
.OriginalFirstThunk: dd (_hintnames - _filestart)
.TimeDateStamp: dd 0
.ForwarderChain: dd 0
.Name: dd (_KERNEL32_str - _filestart)
.FirstThunk: dd (_iat - _filestart)

_idata_data_end:
_eof:
;bss_size equ 0
;IMAGE_IMPORT_DESCRIPTOR__1:  ; Empty, marks end-of-list.
;.OriginalFirstThunk: dd 0
;.TimeDateStamp: dd 0
;.ForwarderChain: dd 0
;.Name: dd 0
;.FirstThunk: dd 0
;_idata_end:
bss_size equ 20  ; _idata_end - _eof

; Padding to reach minimum file size of 268 bytes on 64-bit Windows 7.
; This padding is not needed on 32-bit Windows 7.
times 268 - ($-$$) db 0
