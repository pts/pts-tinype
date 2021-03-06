;
; hh6b.nasm: small (1024 bytes) and ultraportable Win32 PE .exe
; Compile: nasm -O0 -f bin -o hh6b.exe hh6b.nasm
;
; It works on Windows NT 3.1--Windows 10, tested on Windows NT 3.1, Windows
; 95, Windows XP and Wine 5.0.
;
; This file is based on hh6a.nasm, and .data section was merged to the
; .text section to make it 512 bytes smaller.
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
.mz_signature: dw 'MZ';
image_size_lo: dw IMAGE_NT_HEADERS+0x10  ; Should be IMAGE_NT_HEADERS minimum.
dd 0x00000003, 0x00000004, 0x0000ffff
aa $$+0x0010
dd 0x000000b8, 0x00000000, 0x00000040, 0x00000000
aa $$+0x0020
dd 0x00000000, 0x00000000, 0x00000000, 0x00000000
aa $$+0x0030
dd 0x00000000, 0x00000000, 0x00000000, IMAGE_NT_HEADERS
aa $$+0x0040
dd 0x0eba1f0e, 0xcd09b400, 0x4c01b821
int 0x21
db 'This program cannot be run in DOS mode.', 13, 13, 10, '$'
times  0x80-($-$$) db 0  ; !! This can be decreased by making the PE stub smaller.

IMAGE_BASE equ 0x00400000

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
BSS_SIZE EQU 1  ; Why?
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
IMAGE_DIRECTORY_ENTRY_EXPORT:
.VirtualAddress: dd 0x00000000
.Size: dd 0x00000000
IMAGE_DIRECTORY_ENTRY_IMPORT:
.VirtualAddress: dd IMAGE_IMPORT_DESCRIPTORS+(VADDR_TEXT-SECTION_TEXT)
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
.VirtualAddress: dd IMPORT_ADDRESS_TABLE+(VADDR_TEXT-SECTION_TEXT)
.Size: dd IMPORT_ADDRESS_TABLE_end-IMPORT_ADDRESS_TABLE
IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR:  ; Nonzero for .NET .exe.
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_RESERVED:
.VirtualAddress: dd 0
.Size: dd 0

IMAGE_DATA_DIRECTORY_end:
IMAGE_OPTIONAL_HEADER32_end:

aa $$+0x0178
IMAGE_SECTION_HEADER:
IMAGE_SECTION_HEADER__0:
.Name: db '.text'
times ($$-$)&7 db 0
.VirtualSize: dd SECTION_TEXT_end-SECTION_TEXT
VADDR_TEXT equ 0x1000
.VirtualAddress: dd VADDR_TEXT
.SizeOfRawData: dd SECTION_TEXT_end_aligned-SECTION_TEXT
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
push ebp
mov ebp,esp
sub esp,0x8
nop
mov eax, -11  ; STD_OUTPUT_HANDLE.
push eax
call __call__GetStdHandle@4
mov [ebp-0x8], eax
mov eax, 0
push eax
lea eax, [ebp-0x4]
push eax
mov eax, 0xf
push eax
mov eax, message+(IMAGE_BASE+VADDR_TEXT-SECTION_TEXT)
push eax
mov eax, [ebp-0x8]
push eax
call __call__WriteFile@20
mov eax, 0  ; EXIT_SUCCESS.
push eax
call __call__ExitProcess@4
leave
ret

IMPORTED_CALLS:
times ($$-$)&7 db 0
; TODO(pts): Replace these with indirect `call [...]'.
__call__GetStdHandle@4:
;dd 0x203825ff, 0x00000040
jmp [__imp__GetStdHandle@4+(IMAGE_BASE+VADDR_TEXT-SECTION_TEXT)]
dw 0
__call__WriteFile@20:
jmp [__imp__WriteFile@20+(IMAGE_BASE+VADDR_TEXT-SECTION_TEXT)]
dw 0
__call__ExitProcess@4:
jmp [__imp__ExitProcess@4+(IMAGE_BASE+VADDR_TEXT-SECTION_TEXT)]
dw 0

;SECTION_DATA:

message:
db 'Hello, World!', 13, 10, 0
IMAGE_IMPORT_DESCRIPTORS:
IMAGE_IMPORT_DESCRIPTOR_0:  ; Import directory table.
.OriginalFirstThunk: dd IMPORTED_SYMBOL_NAMES+(VADDR_TEXT-SECTION_TEXT)
.TimeDateStamp: dd 0
.ForwarderChain: dd 0
.Name: dd NAME_KERNEL32_DLL+(VADDR_TEXT-SECTION_TEXT)
.FirstThunk: dd IMPORT_ADDRESS_TABLE+(VADDR_TEXT-SECTION_TEXT)
IMAGE_IMPORT_DESCRIPTOR_1:  ; Last Import directory table, marks end-of-list.
dd 0, 0, 0, 0, 0  ; Same fields as above, filled with 0s.
IMAGE_IMPORT_DESCRIPTORS_end:

IMPORT_ADDRESS_TABLE:  ; Import address table. Modified by the PE loader before jumping to _entry.
__imp__GetStdHandle@4: dd NAME_GetStdHandle+(VADDR_TEXT-SECTION_TEXT)
__imp__WriteFile@20: dd NAME_WriteFile+(VADDR_TEXT-SECTION_TEXT)
__imp__ExitProcess@4 dd NAME_ExitProcess+(VADDR_TEXT-SECTION_TEXT)
dd 0  ; Marks end-of-list.
IMPORT_ADDRESS_TABLE_end:

IMPORTED_SYMBOL_NAMES:
; !! To make it smaller, reuse IMPORT_ADDRESS_TABLE for this.
dd NAME_GetStdHandle+(VADDR_TEXT-SECTION_TEXT)
dd NAME_WriteFile+(VADDR_TEXT-SECTION_TEXT)
dd NAME_ExitProcess+(VADDR_TEXT-SECTION_TEXT)
dd 0  ; Marks end-of-list.
NAME_KERNEL32_DLL: db 'kernel32.dll', 0
; The `0, 0, ' is the .Hint.
NAME_GetStdHandle: db 0, 0, 'GetStdHandle', 0
NAME_WriteFile: db 0, 0, 'WriteFile', 0
NAME_ExitProcess: db 0, 0, 'ExitProcess', 0
dd 0  ; Why is this needed? A dw is not enough.
times ($$-$)&15 db 0

SECTION_TEXT_end:
times ($$-$)&511 db 0
SECTION_TEXT_end_aligned:

aa $$+0x0400
