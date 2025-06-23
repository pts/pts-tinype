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

IMAGE_DATA_DIRECTORY_end:
IMAGE_OPTIONAL_HEADER32_end:

aa $$+0x0178
IMAGE_SECTION_HEADER:
IMAGE_SECTION_HEADER__0:
.Name: db '.text'
times ($$-$)&7 db 0
.VirtualSize: dd SECTION_TEXT_end_aligned-SECTION_TEXT
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
IMAGE_IMPORT_DESCRIPTOR_2:
dd 0, 0, 0, 0, 0  ; Same fields as above, filled with 0s. For Windows 95 4.00.950 C HeapAlloc(...) compatibility.
IMAGE_IMPORT_DESCRIPTOR_3:
dd 0, 0, 0, 0, 0  ; Same fields as above, filled with 0s. For Windows 95 4.00.950 C after-boot compatibility.
IMAGE_IMPORT_DESCRIPTORS_end:

IMPORT_ADDRESS_TABLE:  ; Import address table. Modified by the PE loader before jumping to _entry.
__imp__GetStdHandle@4: dd NAME_GetStdHandle+(VADDR_TEXT-SECTION_TEXT)
__imp__WriteFile@20: dd NAME_WriteFile+(VADDR_TEXT-SECTION_TEXT)
__imp__ExitProcess@4 dd NAME_ExitProcess+(VADDR_TEXT-SECTION_TEXT)
dd 0  ; Terminator needed after the function pointers in IMPORT_ADDRESS_TABLE by Windows 95, Windows NT 3.1, Windows NT 4.0, Windows XP, WDOSX and possibly others. Wine 5.0 and ReactOS 0.4.14 don't need it.
IMPORT_ADDRESS_TABLE_end:

IMPORTED_SYMBOL_NAMES:
; !! To make it smaller, reuse IMPORT_ADDRESS_TABLE for this.
dd NAME_GetStdHandle+(VADDR_TEXT-SECTION_TEXT)
dd NAME_WriteFile+(VADDR_TEXT-SECTION_TEXT)
dd NAME_ExitProcess+(VADDR_TEXT-SECTION_TEXT)
dd 0  ; Terminator needed after thane names in IMPORTED_SYMBOL_NAMES by Reactos 0.4.14.

NAME_KERNEL32_DLL: db 'kernel32.dll', 0
; The `0, 0, ' is the .Hint.
NAME_GetStdHandle: db 0, 0, 'GetStdHandle', 0
NAME_WriteFile: db 0, 0, 'WriteFile', 0
NAME_ExitProcess: db 0, 0, 'ExitProcess', 0

SECTION_TEXT_end:
times ($$-$)&511 db 0
SECTION_TEXT_end_aligned:

aa $$+0x0400
