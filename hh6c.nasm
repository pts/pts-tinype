;
; hh6c.nasm: small (713 bytes) and ultraportable Win32 PE .exe
; Compile: nasm -O0 -f bin -o hh6c.exe hh6c.nasm
;
; It works on Windows NT 3.1--Windows 10, tested on Windows NT 3.1, Windows
; 95, Windows XP and Wine 5.0.
;
; This file is based on hh6b.nasm, and the .text section in the file was
; truncated to make it 512 bytes smaller.
;

; Asserts that we are at offset %1 from the beginning of the input file
%macro aa 1
times $-(%1) times 0 nop
times (%1)-$ times 0 nop
%endmacro

bits 32
cpu 386

IMAGE_DOS_HEADER:
aa $$+0x0000
; https://github.com/pts/pts-nasm-fullprog/blob/master/pe_stub1.nasm
.mz_signature: dw 'MZ'
.image_size_lo: dw IMAGE_NT_HEADERS
.image_size_hi: dw 1
dw 0, 1, 0x0fff, -1, 1, -1, 0, 8, 0
aa $$+24
.stub_start:
push ss
pop ds
mov ah, 9  ; WRITE_DOLLAR_STDOUT.
db 0xba  ; 16-bit mov dx, ...
dw 6  ; .stub_msg, based on .stub_data.
int 0x21
db 0xb8  ; 16-bit mov ax, ...
dw 0x4c01  ; EXIT(1).
int 0x21
.stub_msg: db 'Not a DOS program.', 13, 10, '$'
times 60-($-$$) db 0
dd IMAGE_NT_HEADERS
aa $$+0x40

IMAGE_BASE equ 0x00400000  ; Variable.
AFTER_LAST_SECTION_ALIGNMENT equ 1  ; Set it to 512 to get an 1024-byte .exe.
BSS_SIZE EQU 1  ; !! Can it be 0?

IMAGE_NT_HEADERS:
db 'PE', 0, 0

IMAGE_FILE_HEADER:
Machine: dw 0x14c  ; IMAGE_FILE_MACHINE_I386
NumberOfSections: dw (IMAGE_SECTION_HEADER_end-IMAGE_SECTION_HEADER)/40
TimeDateStamp: dd 0
PointerToSymbolTable: dd 0
NumberOfSymbols: dd 0
SizeOfOptionalHeader: dw IMAGE_OPTIONAL_HEADER32_end-IMAGE_OPTIONAL_HEADER32
IMAGE_FILE_RELOCS_STRIPPED equ 1
IMAGE_FILE_EXECUTABLE_IMAGE equ 2
IMAGE_FILE_LINE_NUMS_STRIPPED equ 4
IMAGE_FILE_LOCAL_SYMS_STRIPPED equ 8
IMAGE_FILE_BYTES_REVERSED_LO equ 0x80  ; Deprecated, shouldn't be specified.
IMAGE_FILE_32BIT_MACHINE equ 0x100
IMAGE_FILE_DEBUG_STRIPPED equ 0x200
IMAGE_FILE_DLL equ 0x2000  ; Shouldn't be specified for .exe.
Characteristics: dw IMAGE_FILE_RELOCS_STRIPPED|IMAGE_FILE_EXECUTABLE_IMAGE|IMAGE_FILE_LINE_NUMS_STRIPPED|IMAGE_FILE_LOCAL_SYMS_STRIPPED|IMAGE_FILE_32BIT_MACHINE|IMAGE_FILE_DEBUG_STRIPPED

IMAGE_OPTIONAL_HEADER32:
Magic: dw 0x10b  ; IMAGE_NT_OPTIONAL_HDR32_MAGIC
MajorLinkerVersion: db 6
MinorLinkerVersion: db 0
SizeOfCode: dd 0x00000000
SizeOfInitializedData: dd 0x00000000
SizeOfUninitializedData: dd 0x00000000
AddressOfEntryPoint: dd _start+(VADDR_TEXT-SECTION_TEXT)  ; Also called starting address.
BaseOfCode: dd VADDR_TEXT
BaseOfData: dd VADDR_TEXT
ImageBase: dd IMAGE_BASE
SectionAlignment: dd 0x1000  ; Single allowed value for Windows XP.
FileAlignment: dd 0x200  ; Minimum value for Windows NT 3.1.
MajorOperatingSystemVersion: dw 4
MinorOperatingSystemVersion: dw 0
MajorImageVersion: dw 0
MinorImageVersion: dw 0
MajorSubsystemVersion: dw 3   ; Windows NT 3.1.
MinorSubsystemVersion: dw 10  ; Windows NT 3.1.
Win32VersionValue: dd 0
SizeOfImage: dd ((SECTION_TEXT_end-SECTION_TEXT+4095)&~4095)+((BSS_SIZE+4095)&~4095)
SizeOfHeaders: dd HEADERS_end_aligned
CheckSum: dd 0xd43c  ; !! Change to 0 to avoid checking.
Subsystem: dw 3  ; IMAGE_SUBSYSTEM_WINDOWS_CUI; gcc -mconsole
DllCharacteristics: dw 0
SizeOfStackReserve: dd 0x00100000
SizeOfStackCommit: dd 0x00001000
SizeOfHeapReserve: dd 0x100000  ; Why not 0?
SizeOfHeapCommit: dd 0x1000  ; Why not 0?
LoaderFlags: dd 0
NumberOfRvaAndSizes: dd (IMAGE_DATA_DIRECTORY_end-IMAGE_DATA_DIRECTORY)/8
IMAGE_DATA_DIRECTORY:
IMAGE_DIRECTORY_ENTRY_EXPORT:  ; 0.
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_IMPORT:  ; 1. Import directory.
.VirtualAddress: dd IMAGE_IMPORT_DESCRIPTORS+(VADDR_TEXT-SECTION_TEXT)
.Size: dd IMAGE_IMPORT_DESCRIPTORS_end-IMAGE_IMPORT_DESCRIPTORS
IMAGE_DIRECTORY_ENTRY_RESOURCE:  ; 2.
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_EXCEPTION:  ; 3.
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_SECURITY:  ; 4.
.VirtualAddress: dd 0
.Size: dd 0
%if 0  ; Windows 95 needs >=5. Windows NT 3.1, Windows NT 4.0 and Windows XP neesd >=5 or less. Wine 5.0 needs >=2. WDOSX needs >=6 because it needs relocations in IMAGE_DIRECTORY_ENTRY_BASERELOC.
IMAGE_DIRECTORY_ENTRY_BASERELOC:  ; 5. Base relocation directory.
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_DEBUG:  ; 6.
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_ARCHITECTURE:  ; 7.
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_GLOBALPTR:  ; 8.
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_TLS:  ; 9.
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG:  ; 10.
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT:  ; 11.
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_IAT:  ; 12. Import address table. Omitted by OpenWatcom wlink(1).
.VirtualAddress: dd IMPORT_ADDRESS_TABLE+(VADDR_TEXT-SECTION_TEXT)
.Size: dd IMPORT_ADDRESS_TABLE_end-IMPORT_ADDRESS_TABLE
IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT:  ; 13.
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR:  ; 14. Nonzero for .NET .exe.
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_RESERVED:  ; 15.
.VirtualAddress: dd 0
.Size: dd 0
%endif
IMAGE_DATA_DIRECTORY_end:
IMAGE_OPTIONAL_HEADER32_end:

IMAGE_SECTION_HEADER:
IMAGE_SECTION_HEADER__0:
.Name: db '.text'
times ($$-$)&7 db 0
.VirtualSize: dd SECTION_TEXT_end-SECTION_TEXT
VADDR_TEXT equ 0x1000
.VirtualAddress: dd VADDR_TEXT
.SizeOfRawData: dd SECTION_TEXT_end_aligned-SECTION_TEXT  ; Byte size in file. Windows NT 3.1 fails if this is larger than the actual file.
.PointerToRawData: dd SECTION_TEXT
.PointerToRelocations: dd 0
.PointerToLineNumbers: dd 0
.NumberOfRelocations: dw 0
.NumberOfLineNumbers: dw 0
IMAGE_SCN_CNT_CODE equ 0x20
IMAGE_SCN_MEM_EXECUTE equ 0x20000000
IMAGE_SCN_MEM_READ equ 0x40000000
IMAGE_SCN_CNT_INITIALIZED_DATA equ 0x40
IMAGE_SCN_MEM_WRITE equ 0x80000000
.Characteristics: dd IMAGE_SCN_CNT_CODE|IMAGE_SCN_MEM_EXECUTE|IMAGE_SCN_MEM_READ|IMAGE_SCN_CNT_INITIALIZED_DATA|IMAGE_SCN_MEM_WRITE

IMAGE_SECTION_HEADER_end:
times ($$-$)&511 db 0
HEADERS_end_aligned:

SECTION_TEXT:
aa $$+0x0200
_start:
push strict byte -11  ; STD_OUTPUT_HANDLE.
call [__imp__GetStdHandle@4+(IMAGE_BASE+VADDR_TEXT-SECTION_TEXT)]
;push eax  ; Save stdout handle.
push eax  ; Value is arbitrary, we allocate an output variable on the stack.
mov ebx, esp
push strict byte 0  ; Argument 5: lpOverlapped = 0.
push ebx  ; Argument 4: Address of the output variable.
push strict byte message_end-message  ; Argument 3: message size.
push strict dword message+(IMAGE_BASE+VADDR_TEXT-SECTION_TEXT)  ; Argument 2: message.
push eax  ; if it was saved, strict dword [esp+20]  ; Argument 1: Stdout handle.
call [__imp__WriteFile@20+(IMAGE_BASE+VADDR_TEXT-SECTION_TEXT)]
push byte 0  ; EXIT_SUCCESS == 0.
call [__imp__ExitProcess@4+(IMAGE_BASE+VADDR_TEXT-SECTION_TEXT)]
;add esp, 8  ; Too late, we've already exited.
;ret  ; Too late, we've already exited.

;SECTION_DATA:

message:
db 'Hello, World!', 13, 10
message_end:
IMAGE_IMPORT_DESCRIPTORS:
IMAGE_IMPORT_DESCRIPTOR_0:
.OriginalFirstThunk: dd IMPORT_ADDRESS_TABLE+(VADDR_TEXT-SECTION_TEXT)
.TimeDateStamp: dd 0
.ForwarderChain: dd 0
.Name: dd NAME_KERNEL32_DLL+(VADDR_TEXT-SECTION_TEXT)
.FirstThunk: dd IMPORT_ADDRESS_TABLE+(VADDR_TEXT-SECTION_TEXT)
IMAGE_IMPORT_DESCRIPTOR_1:  ; Last Import directory table, marks end-of-list.
dd 0, 0, 0, 0, 0  ; Same fields as above, filled with 0s.
IMAGE_IMPORT_DESCRIPTOR_2:
dd 0, 0, 0, 0, 0  ; Same fields as above, filled with 0s. For Windows 95 4.00.950 C HeapAlloc(...) compatibility.
IMAGE_IMPORT_DESCRIPTOR_3:
dd 0, 0, 0, 0, 0  ; Same fields as above, filled with 0s. For Windows 95 4.00.950 C after-boot compatibility.
IMAGE_IMPORT_DESCRIPTORS_end:

IMPORT_ADDRESS_TABLE:  ; Import address table. Modified by the PE loader before jumping to _entry.
__imp__GetStdHandle@4: dd NAME_GetStdHandle+(VADDR_TEXT-SECTION_TEXT)
__imp__WriteFile@20: dd NAME_WriteFile+(VADDR_TEXT-SECTION_TEXT)
__imp__ExitProcess@4 dd NAME_ExitProcess+(VADDR_TEXT-SECTION_TEXT)
dd 0  ; Terminator needed after the function pointers in IMPORT_ADDRESS_TABLE by Windows 95, Windows NT 3.1, Windows NT 4.0, Windows XP, WDOSX and possibly others. Wine 5.0 doesn't need it.
IMPORT_ADDRESS_TABLE_end:

%define NAME_ODD  0  ; Names with an odd  length are terminated by 1 NUL, to make the full name even size.
; OpenWatcom wlink(1) would add an extra 0 for names with an even length, to
; enforce even name alignment. But that's not needed, so we don't add it.
%if 1
  %define NAME_EVEN 0  ; Names with an even length are also terminated by 1 NUL, not making the full name even size.
%else
  %define NAME_EVEN 0, 0  ; Names with an even length are terminated by 2 NULs, to make the full name even size.
%endif
NAME_KERNEL32_DLL: db 'kernel32.dll', NAME_EVEN
; The `0, 0, ' is the .Hint.
NAME_GetStdHandle: db 0, 0, 'GetStdHandle', NAME_EVEN
NAME_WriteFile: db 0, 0, 'WriteFile', NAME_ODD
NAME_ExitProcess: db 0, 0, 'ExitProcess', NAME_ODD

SECTION_TEXT_end:
times (($$-$) %% AFTER_LAST_SECTION_ALIGNMENT+AFTER_LAST_SECTION_ALIGNMENT)%AFTER_LAST_SECTION_ALIGNMENT db 0
SECTION_TEXT_end_aligned:
;aa $$+0x0400
