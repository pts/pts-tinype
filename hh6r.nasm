;
; hh6r.nasm: small and ultraportable Win32 console PE .exe with relocations
; by pts@fazekas.hu on Mon Aug  3 20:03:00 CEST 2020
;
; Compile: nasm -O0 -f bin -o hh6r.exe hh6r.nasm
;
; It works on Windows NT 3.1--Windows 10, tested on Windows NT 3.1, Windows
; 95, Windows XP, Windows 7, Windows 10, Wine 5.0 and ReactOS 0.4.14.
;
; This file is based on hh6d.nasm, and relocations were added.
;
; On 2025-06-24:
;
; https://www.virustotal.com/gui/file/d6c53a4ac32841b2293cb51c371e1775d596fb8649ca83a9d0bd66d8161f844e?nocache=1
; Arctic Wolf: Unsafe
; Avira (no cloud): TR/Patched.Ren.Gen
; Cynet: Malicious (score: 99)
; DeepInstinct: MALICIOUS
; Elastic: Malicious (moderate Confidence)
; Google: Detected
; Microsoft: Trojan:Win32/Wacatac.B!ml
; Rising: Trojan.Kryptik@AI.96 (RDML:14uBNpYiYUAV6s8jTsAdzw)
; Sophos: Mal/EncPk-ABO
; Trapmine: Malicious.high.ml.score
; WithSecure: Trojan.TR/Patched.Ren.Gen
; ZoneAlarm by Check Point: Mal/EncPk-ABO
;

; Asserts that we are at offset %1 from the beginning of the input file
%macro aa 1
times $-(%1) times 0 nop
times (%1)-$ times 0 nop
%endmacro

bits 32
cpu 386

SECTION_HEADER:
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
IMAGE_FILE_RELOCS_STRIPPED equ 1
IMAGE_FILE_EXECUTABLE_IMAGE equ 2
IMAGE_FILE_LINE_NUMS_STRIPPED equ 4
IMAGE_FILE_LOCAL_SYMS_STRIPPED equ 8
IMAGE_FILE_BYTES_REVERSED_LO equ 0x80  ; Deprecated, shouldn't be specified.
IMAGE_FILE_32BIT_MACHINE equ 0x100
IMAGE_FILE_DEBUG_STRIPPED equ 0x200
IMAGE_FILE_DLL equ 0x2000  ; Shouldn't be specified for .exe.
Characteristics: dw IMAGE_FILE_EXECUTABLE_IMAGE|IMAGE_FILE_LINE_NUMS_STRIPPED|IMAGE_FILE_LOCAL_SYMS_STRIPPED|IMAGE_FILE_32BIT_MACHINE|IMAGE_FILE_DEBUG_STRIPPED  ; Doesn't have IMAGE_FILE_RELOCS_STRIPPED.

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
IMAGE_DIRECTORY_ENTRY_EXPORT:  ; 0.
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_IMPORT:  ; 1. Import directory.
.VirtualAddress: dd IMAGE_IMPORT_DESCRIPTORS+(VADDR_TEXT-HEADER_end_aligned)
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
.VirtualAddress: dd RELOC_BLOCKS+(VADDR_HEADER-SECTION_HEADER)
.Size: dd RELOC_BLOCKS_end-RELOC_BLOCKS
IMAGE_DIRECTORY_ENTRY_DEBUG:  ; 6.
.VirtualAddress: dd 0
.Size: dd 0
%if 0  ; Windows XP needs >=7 if relocations are present. Windows 95, Windows NT 3.1, Windows NT 4.0 and WDOSX need >=6 (the minimum for IMAGE_DIRECTORY_ENTRY_BASERELOC).
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
.VirtualAddress: dd IMPORT_ADDRESS_TABLE+(VADDR_TEXT-HEADER_end_aligned)
.Size: dd IMPORT_ADDRESS_TABLE_end-IMPORT_ADDRESS_TABLE
; These entries are not needed.
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
.VirtualSize: dd SECTION_TEXT_end-HEADER_end_aligned+EXTRA_BSS_SIZE+BSS_SIZE
VADDR_TEXT equ 0x1000
.VirtualAddress: dd VADDR_TEXT
.SizeOfRawData: dd SECTION_TEXT_end-HEADER_end_aligned  ; Byte size in file. Windows NT 3.1 fails if this is larger than the actual file.
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

message:
db 'Hello, World!', 13, 10
message_end:

; Without these relocation blocks, Win32s wouldn't be able to run the .exe.
; They are ignored by Wine, Windows NT, Windows 95 and Windows XP+.
RELOC_BLOCKS:  ; https://learn.microsoft.com/en-us/windows/win32/debug/pe-format#the-reloc-section-image-only
RELOC_BLOCK__0:  ; Each block must start on a 32-bit boundary.
dd VADDR_TEXT                             ; dd 0x1000
dd RELOC_BLOCK__0_end-RELOC_BLOCK__0      ; dd 0x10
.relocs:
BASERELOC_HIGHLOW equ 0x3000  ; IMAGE_REL_BASED_HIGHLOW (== 3) << 12. The lower 12 bits contain the actual offset where to apply the relocation.
dw reloc0-SECTION_TEXT+BASERELOC_HIGHLOW  ; dw 0x3004
dw reloc1-SECTION_TEXT+BASERELOC_HIGHLOW  ; dw 0x3011
dw reloc2-SECTION_TEXT+BASERELOC_HIGHLOW  ; dw 0x3018
dw reloc3-SECTION_TEXT+BASERELOC_HIGHLOW  ; dw 0x3020
%if ($-.relocs)&2  ; !! Is this padding really needed? Which Windows version breaks without it?
dw 0  ; Padding to even number of relocs. IMAGE_REL_BASED_ABSOLUTE to pad a block.
%endif
RELOC_BLOCK__0_end:
RELOC_BLOCKS_end:

HEADERS_end:

%if $-FILE_HEADER<HEADER_end_aligned
times HEADER_end_aligned-($-FILE_HEADER) db 'R'
%endif
SECTION_TEXT:

_start:
push strict byte -11  ; STD_OUTPUT_HANDLE.
call [__imp__GetStdHandle@4+(IMAGE_BASE+VADDR_TEXT-HEADER_end_aligned)]
reloc0 equ $-4
;push eax  ; Save stdout handle.
push eax  ; Value is arbitrary, we allocate an output variable on the stack.
mov ebx, esp
push strict byte 0  ; Argument 5: lpOverlapped = 0.
push ebx  ; Argument 4: Address of the output variable.
push strict byte message_end-message  ; Argument 3: message size.
push strict dword message+(IMAGE_BASE+VADDR_HEADER)  ; Argument 2: message.
reloc1 equ $-4
push eax  ; if it was saved, strict dword [esp+20]  ; Argument 1: Stdout handle.
call [__imp__WriteFile@20+(IMAGE_BASE+VADDR_TEXT-HEADER_end_aligned)]
reloc2 equ $-4
push byte 0  ; EXIT_SUCCESS == 0.
call [__imp__ExitProcess@4+(IMAGE_BASE+VADDR_TEXT-HEADER_end_aligned)]
reloc3 equ $-4
;add esp, 8  ; Too late, we've already exited.
;ret  ; Too late, we've already exited.

;SECTION_DATA:

; Because of the modification, this must start after SECTION_TEXT.
IMPORT_ADDRESS_TABLE:  ; Import address table. Modified by the PE loader before jumping to _entry.
__imp__GetStdHandle@4: dd NAME_GetStdHandle+(VADDR_HEADER)
__imp__WriteFile@20: dd NAME_WriteFile+(VADDR_HEADER)
__imp__ExitProcess@4 dd NAME_ExitProcess+(VADDR_HEADER)
dd 0  ; Terminator needed after the function pointers in IMPORT_ADDRESS_TABLE by Windows 95, Windows NT 3.1, Windows NT 4.0, Windows XP, WDOSX and possibly others. Wine 5.0 doesn't need it.
IMPORT_ADDRESS_TABLE_end:

;dd 0, 0, 0;, 0  ; Doesn't help.

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
; For the end-of-list bytes above + one more all-0 descriptor, for
; Windows 95 4.00.950 C HeapAlloc(...) and after-boot compatibility.
EXTRA_BSS_SIZE equ (4*5)+4
IMAGE_IMPORT_DESCRIPTORS_end equ $+EXTRA_BSS_SIZE

SECTION_TEXT_end:
