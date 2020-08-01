;
; hh6d.nasm: small (584 bytes) and ultraportable Win32 PE .exe
; by pts@fazekas.hu on 2020-07-25
;
; Compile: nasm -O0 -f bin -o hh6d.exe hh6d.nasm
;
; It works on Windows NT 3.1--Windows 10, tested on Windows NT 3.1, Windows
; 95, Windows XP, Windows 7, Windows 10 and Wine 5.0.
;
; This file is based on hh6c.nasm. Some padding bytes and some image data
; directory entried were removed, and some read-only data has been moved
; from the .text section to the header.
;

; Asserts that we are at offset %1 from the beginning of the input file
%macro aa 1
times $-(%1) times 0 nop
times (%1)-$ times 0 nop
%endmacro

bits 32
cpu 386

VADDR_HEADER equ 0
FILE_HEADER:
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
;IMAGE_BASE equ 0x10000000  ; Also works on Windows NT 3.1.
BSS_SIZE EQU 0
;HEADER_end_aligned EQU 0x400
HEADER_end_aligned EQU 0x200

IMAGE_NT_HEADERS:
db 'PE', 0, 0

IMAGE_FILE_HEADER:
Machine: dw 0x14c  ; IMAGE_FILE_MACHINE_I386
NumberOfSections: dw (IMAGE_SECTION_HEADER_end-IMAGE_SECTION_HEADER)/40
TimeDateStamp: dd 0
PointerToSymbolTable: dd 0
NumberOfSymbols: dd 0
SizeOfOptionalHeader: dw IMAGE_OPTIONAL_HEADER32_end-IMAGE_OPTIONAL_HEADER32
Characteristics: dw 0x030f

IMAGE_OPTIONAL_HEADER32:
Magic: dw 0x10b  ; IMAGE_NT_OPTIONAL_HDR32_MAGIC
MajorLinkerVersion: db 6
MinorLinkerVersion: db 0
SizeOfCode: dd 0x00000000
SizeOfInitializedData: dd 0x00000000
SizeOfUninitializedData: dd 0x00000000
AddressOfEntryPoint: dd _start+(VADDR_TEXT-HEADER_end_aligned)  ; Also called starting address.
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
SizeOfImage: dd VADDR_TEXT+SECTION_TEXT_end-HEADER_end_aligned+EXTRA_BSS_SIZE+BSS_SIZE
SizeOfHeaders: dd HEADERS_end
CheckSum: dd 0
Subsystem: dw 3  ; IMAGE_SUBSYSTEM_WINDOWS_CUI; gcc -mconsole
DllCharacteristics: dw 0
SizeOfStackReserve: dd 0x00100000
SizeOfStackCommit: dd 0x00001000
SizeOfHeapReserve: dd 0x100000  ; Why not 0?
SizeOfHeapCommit: dd 0x1000  ; Why not 0?
LoaderFlags: dd 0
NumberOfRvaAndSizes: dd (IMAGE_DATA_DIRECTORY_end-IMAGE_DATA_DIRECTORY)/8
IMAGE_DATA_DIRECTORY:
IMAGE_DIRECTORY_ENTRY_EXPORT:
.VirtualAddress: dd 0x00000000
.Size: dd 0x00000000
IMAGE_DIRECTORY_ENTRY_IMPORT:
.VirtualAddress: dd IMAGE_IMPORT_DESCRIPTORS+(VADDR_TEXT-HEADER_end_aligned)
.Size: dd IMAGE_IMPORT_DESCRIPTORS_end-IMAGE_IMPORT_DESCRIPTORS
IMAGE_DIRECTORY_ENTRY_RESOURCE:
.VirtualAddress: dd 0x00000000
.Size: dd 0x00000000
IMAGE_DIRECTORY_ENTRY_EXCEPTION:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_SECURITY:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_BASERELOC:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_DEBUG:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_ARCHITECTURE:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_GLOBALPTR:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_TLS:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_IAT:  ; Import address table.
.VirtualAddress: dd IMPORT_ADDRESS_TABLE+(VADDR_TEXT-HEADER_end_aligned)
.Size: dd IMPORT_ADDRESS_TABLE_end-IMPORT_ADDRESS_TABLE
; These entries are not needed.
;IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT:
;.VirtualAddress: dd 0
;.Size: dd 0
;IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR:  ; Nonzero for .NET .exe.
;.VirtualAddress: dd 0
;.Size: dd 0
;IMAGE_DIRECTORY_ENTRY_RESERVED:
;.VirtualAddress: dd 0
;.Size: dd 0

IMAGE_DATA_DIRECTORY_end:
IMAGE_OPTIONAL_HEADER32_end:

IMAGE_SECTION_HEADER:
IMAGE_SECTION_HEADER__0:
.Name: db '.text'
times ($$-$)&7 db 0
.VirtualSize: dd SECTION_TEXT_end-HEADER_end_aligned+EXTRA_BSS_SIZE+BSS_SIZE
VADDR_TEXT equ 0x1000
.VirtualAddress: dd VADDR_TEXT
.SizeOfRawData: dd SECTION_TEXT_end-HEADER_end_aligned
.PointerToRawData: dd HEADER_end_aligned
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

NAME_KERNEL32_DLL: db 'kernel32.dll', 0
; The `0, 0, ' is the .Hint.
NAME_GetStdHandle: db 0, 0, 'GetStdHandle', 0
NAME_WriteFile: db 0, 0, 'WriteFile', 0
NAME_ExitProcess: db 0, 0, 'ExitProcess', 0
dd 0  ; Why is this needed? A dw is not enough.

message:
;db 'Hello, World! MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM', 13, 10, 'MSG', 13, 10
db 'Hello, World!', 13, 10
message_end:

HEADERS_end:

%if $-FILE_HEADER<HEADER_end_aligned
times HEADER_end_aligned-($-FILE_HEADER) db 'H'
%endif
SECTION_TEXT:

_start:
push strict byte -11  ; STD_OUTPUT_HANDLE.
call [__imp__GetStdHandle@4+(IMAGE_BASE+VADDR_TEXT-HEADER_end_aligned)]
;push eax  ; Save stdout handle.
push eax  ; Value is arbitrary, we allocate an output variable on the stack.
mov ebx, esp
push strict byte 0  ; Argument 5: lpOverlapped = 0.
push ebx  ; Argument 4: Address of the output variable.
push strict byte message_end-message  ; Argument 3: message size.
push strict dword message+(IMAGE_BASE+VADDR_HEADER)  ; Argument 2: message.
push eax  ; if it was saved, strict dword [esp+20]  ; Argument 1: Stdout handle.
call [__imp__WriteFile@20+(IMAGE_BASE+VADDR_TEXT-HEADER_end_aligned)]
push byte 0  ; EXIT_SUCCESS == 0.
call [__imp__ExitProcess@4+(IMAGE_BASE+VADDR_TEXT-HEADER_end_aligned)]
;add esp, 8  ; Too late, we've already exited.
;ret  ; Too late, we've already exited.

;SECTION_DATA:

; Because of the modification, this must start after SECTION_TEXT.
IMPORT_ADDRESS_TABLE:  ; Import address table. Modified by the PE loader before jumping to _entry.
__imp__GetStdHandle@4: dd NAME_GetStdHandle+(VADDR_HEADER)
__imp__WriteFile@20: dd NAME_WriteFile+(VADDR_HEADER)
__imp__ExitProcess@4 dd NAME_ExitProcess+(VADDR_HEADER)
dd 0  ; Marks end-of-list.
IMPORT_ADDRESS_TABLE_end:


SECTION_TEXT_end:

; Windows 95 requires this to be part of a section; Windows NT 3.1 and
; Windows XP work if this is in the header.
IMAGE_IMPORT_DESCRIPTORS:
IMAGE_IMPORT_DESCRIPTOR_0:
.OriginalFirstThunk: dd IMPORT_ADDRESS_TABLE+(VADDR_TEXT-HEADER_end_aligned)
.TimeDateStamp: dd 0
.ForwarderChain: dd 0
.Name: dd NAME_KERNEL32_DLL+(VADDR_HEADER)  ; !!!
.FirstThunk: dd IMPORT_ADDRESS_TABLE+(VADDR_TEXT-HEADER_end_aligned)
IMAGE_IMPORT_DESCRIPTOR_1:  ; Last Import directory table, marks end-of-list.
;dd 0, 0, 0, 0, 0  ; Same fields as above, filled with 0s.
EXTRA_BSS_SIZE equ 4*5  ; For the end-of-list bytes above.
IMAGE_IMPORT_DESCRIPTORS_end equ $+EXTRA_BSS_SIZE
