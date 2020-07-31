;
; hh3tgn.nasm: a NASM reimplementation of hh3tg.golden.exe
; by pts@fazekas.hu at Fri Jul 31 23:39:25 CEST 2020
;
; Compile: nasm -O0 -f bin -o hh3tgn.exe hh3tgn.nasm
;
; It works on Win32s, Windows NT 3.1--Windows 10, tested on Windows NT 3.1,
; Windows 95, Windows XP and Wine 5.0.
;

bits 32
cpu 386

; Asserts that we are at offset %1 from the beginning of the input file
%macro aa 1
times $-(%1) times 0 nop
times (%1)-$ times 0 nop
%endmacro

IMAGE_BASE equ 0x400000

SECTION_HEADER:
VADDR_HEADER equ 0
IMAGE_DOS_HEADER:
aa $$+0x0000
.mz_signature: dw 'MZ'
dw 0x90, 3, 0, 4, 0, -1, 0
aa $$+0x0010
dw 0xb8, 0, 0, 0, 0x40, 0
aa $$+0x001c
times 60-($-IMAGE_DOS_HEADER) db 0
dd IMAGE_NT_HEADERS-VADDR_HEADER
aa $$+0x0040
.stub_start:
push cs
pop ds
db 0xBA  ; 16-bit mov dx, ...
dw .stub_msg-.stub_start
mov ah, 9
int 0x21
db 0xB8  ; 16-bit mov ax, ...
dw 0x4c01
int 0x21
.stub_msg:
aa $$+0x004e
db 'This program cannot be run in DOS mode.', 13, 13, 10, '$'
times 0x80-($-IMAGE_DOS_HEADER) db 0

IMAGE_NT_HEADERS:
aa $$+0x0080
db 'PE', 0, 0
IMAGE_FILE_HEADER:
Machine: dw 0x14c  ; IMAGE_FILE_MACHINE_I386
NumberOfSections: dw (IMAGE_SECTION_HEADER_end-IMAGE_SECTION_HEADER)/40
DateTimeStamp: dd 0x5f241d55  ; !! 0
PointerToSymbolTable: dd 0
aa $$+0x0090
NumberOfSymbols: dd 0
SizeOfOptionalHeader: dw IMAGE_OPTIONAL_HEADER32_end-IMAGE_OPTIONAL_HEADER32
IMAGE_FILE_RELOCS_STRIPPED equ 1
Characteristics: dw 0x030e  ; Doesn't have IMAGE_FILE_RELOCS_STRIPPED.

IMAGE_OPTIONAL_HEADER32:
aa $$+0x0098
Magic: dw 0x10b  ; IMAGE_NT_OPTIONAL_HDR32_MAGIC
MajorLinkerVersion: db 2
MinorLinkerVersion: db 0x22
SizeOfCode: dd 0x00000200  ; !! 0
aa $$+0x00a0
SizeOfInitializedData: dd 0x00000600  ; !! 0
SizeOfUninitialiedData: dd 0
AddressOfEntryPoint: dd _start+(VADDR_TEXT-SECTION_TEXT)  ; Also called starting address.
BaseOfCode: dd VADDR_TEXT
aa $$+0x00b0
BaseOfData: dd 0x00000000  ; !! VADDR_TEXT
ImageBase: dd IMAGE_BASE
SectionAlignment: dd 0x1000  ; Single allowed value for Windows XP.
FileAlignment: dd 0x200  ; Minimum value for Windows NT 3.1.
aa $$+0x00c0
MajorOperatingSystemVersion: dw 4
MinorOperatingSystemVersion: dw 0
MajorImageVersion: dw 1  ; !! 0
MinorImageVersion: dw 0
MajorSubsystemVersion: dw 3   ; Windows NT 3.1.
MinorSubsystemVersion: dw 10  ; Windows NT 3.1.
Win32VersionValue: dd 0
aa $$+0x00d0
;BSS_SIZE EQU 1  ; Why?
SizeOfImage: dd 0x5000  ; !! ((SECTION_TEXT_end-SECTION_TEXT+4095)&~4095)+((BSS_SIZE+4095)&~4095)
SizeOfHeaders: dd SECTION_HEADER_end_aligned
CheckSum: dd 0x6229  ; !! Change to 0 to avoid checking.
Subsystem: dw 2  ; IMAGE_SUBSYSTEM_WINDOWS_GUI; gcc -mwindows
IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE equ 0x40
dw IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE  ; !!! 0 DllCharacteristics
aa $$+0x00e0
SizeOfStackReserve: dd 0x00200000  ; !! 0x00100000
SizeOfStackCommit: dd 0x00001000
SizeOfHeapReserve: dd 0x100000  ; Why not 0?
SizeOfHeapCommit: dd 0x1000  ; Why not 0?
aa $$+0x00f0
LoaderFlags: dd 0
NumberOfRvaAndSizes: dd (IMAGE_DATA_DIRECTORY_end-IMAGE_DATA_DIRECTORY)/8
IMAGE_DATA_DIRECTORY:
IMAGE_DIRECTORY_ENTRY_EXPORT:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_IMPORT:
aa $$+0x0100
.VirtualAddress: dd IMAGE_IMPORT_DESCRIPTORS+(VADDR_IDATA-SECTION_IDATA)
.Size: dd IMAGE_IMPORT_DESCRIPTORS_end-IMAGE_IMPORT_DESCRIPTORS
IMAGE_DIRECTORY_ENTRY_RESOURCE:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_EXCEPTION:
aa $$+0x0110
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_SECURITY:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_BASERELOC:
aa $$+0x0120
.VirtualAddress: dd RELOC_BLOCKS+(VADDR_RELOC-SECTION_RELOC)
.Size: dd RELOC_BLOCKS_end-RELOC_BLOCKS
IMAGE_DIRECTORY_ENTRY_DEBUG:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_ARCHITECTURE:
aa $$+0x0130
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_GLOBALPTR:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_TLS:
aa $$+0x0140
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT:
aa $$+0x0150
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_IAT:  ; Import address table.
.VirtualAddress: dd IMPORT_ADDRESS_TABLE+(VADDR_IDATA-SECTION_IDATA)
.Size: dd IMPORT_ADDRESS_TABLE_end-IMPORT_ADDRESS_TABLE
IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT:
aa $$+0x0160
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR:  ; Nonzero for .NET .exe.
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_RESERVED:
aa $$+0x0170
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DATA_DIRECTORY_end:
IMAGE_OPTIONAL_HEADER32_end:
IMAGE_SECTION_HEADER:

IMAGE_SECTION_HEADER__0:
aa $$+0x0178
.Name: db '.text'
times (.Name-$)&7 db 0
aa $$+0x0180
.VirtualSize: dd SECTION_TEXT_end-SECTION_TEXT
.VirtualAddress: dd VADDR_TEXT
.SizeOfRawData: dd SECTION_TEXT_end_aligned-SECTION_TEXT
.PointerToRawData: dd SECTION_TEXT-SECTION_HEADER
.PointerToRelocations: dd 0
.PointerToLineNumbers: dd 0
.NumberOfRelocations: dw 0
.NumberOfLineNumbers: dw 0
IMAGE_SCN_CNT_CODE equ 0x20
IMAGE_SCN_MEM_EXECUTE equ 0x20000000
IMAGE_SCN_MEM_READ equ 0x40000000
IMAGE_SCN_CNT_INITIALIZED_DATA equ 0x40
IMAGE_SCN_MEM_WRITE equ 0x80000000
IMAGE_SCN_ALIGN_4BYTES equ 0x00300000  ; !!
IMAGE_SCN_MEM_DISCARDABLE equ 0x02000000  ; !!
.Characteristics: dd IMAGE_SCN_CNT_CODE|IMAGE_SCN_ALIGN_4BYTES|IMAGE_SCN_MEM_EXECUTE|IMAGE_SCN_MEM_READ

IMAGE_SECTION_HEADER__1:
aa $$+0x01a0
.Name: db '.rdata'
times (.Name-$)&7 db 0
.VirtualSize: dd SECTION_RDATA_end-SECTION_RDATA
.VirtualAddress: dd VADDR_RDATA
.SizeOfRawData: dd SECTION_RDATA_end_aligned-SECTION_RDATA
.PointerToRawData: dd SECTION_RDATA-SECTION_HEADER
.PointerToRelocations: dd 0
.PointerToLineNumbers: dd 0
.NumberOfRelocations: dw 0
.NumberOfLineNumbers: dw 0
.Characteristics: dd IMAGE_SCN_CNT_INITIALIZED_DATA|IMAGE_SCN_ALIGN_4BYTES|IMAGE_SCN_MEM_READ

IMAGE_SECTION_HEADER__2:
aa $$+0x01c8
.Name: db '.idata'
times (.Name-$)&7 db 0
.VirtualSize: dd SECTION_IDATA_end-SECTION_IDATA
.VirtualAddress: dd VADDR_IDATA
.SizeOfRawData: dd SECTION_IDATA_end_aligned-SECTION_IDATA
.PointerToRawData: dd SECTION_IDATA-SECTION_HEADER
.PointerToRelocations: dd 0
.PointerToLineNumbers: dd 0
.NumberOfRelocations: dw 0
.NumberOfLineNumbers: dw 0
.Characteristics: dd IMAGE_SCN_CNT_INITIALIZED_DATA|IMAGE_SCN_ALIGN_4BYTES|IMAGE_SCN_MEM_READ|IMAGE_SCN_MEM_WRITE

IMAGE_SECTION_HEADER__3:
aa $$+0x01f0
.Name: db '.reloc'
times (.Name-$)&7 db 0
.VirtualSize: dd SECTION_RELOC_end-SECTION_RELOC
.VirtualAddress: dd VADDR_RELOC
.SizeOfRawData: dd SECTION_RELOC_end_aligned-SECTION_RELOC
.PointerToRawData: dd SECTION_RELOC-SECTION_HEADER
.PointerToRelocations: dd 0
.PointerToLineNumbers: dd 0
.NumberOfRelocations: dw 0
.NumberOfLineNumbers: dw 0
.Characteristics: dd IMAGE_SCN_CNT_INITIALIZED_DATA|IMAGE_SCN_ALIGN_4BYTES|IMAGE_SCN_MEM_DISCARDABLE|IMAGE_SCN_MEM_READ
aa $$+0x0218

IMAGE_SECTION_HEADER_end:
SECTION_HEADER_end:
times 0x400-($-SECTION_HEADER) db 0
SECTION_HEADER_end_aligned:

SECTION_TEXT:
VADDR_TEXT equ 0x1000
aa $$+0x0400
_start:
sub esp,byte +0x10              ;00001000  83EC10
db 0xc7, 0x04, 0x24
dd user32_dll_str-SECTION_RDATA+VADDR_RDATA+IMAGE_BASE  ; mov dword [esp],...        ;00001003  C7042400204000
reloc0 equ $-4
call [dword LoadLibraryA_addr-SECTION_IDATA+VADDR_IDATA+IMAGE_BASE]           ;0000100A  FF1540304000
reloc1 equ $-4
push ecx                        ;00001010  51
test eax,eax                    ;00001011  85C0
jnz .l2                         ;00001013  7507
.l1:
mov eax,99                      ;00001015  B863000000
jmp strict short .l3            ;0000101A  EB3B
.l2:
mov dword [byte esp+0x4], MessageBoxA_str-SECTION_RDATA+VADDR_RDATA+IMAGE_BASE  ;  strict dword MessageBoxA_str+IMAGE_BASE-SECTION_RDATA+VADDR_RDATA    ;0000101C  C7442404 0B204000
reloc2 equ $-4
mov [esp],eax                   ;00001024  890424
call [dword GetProcAddress_addr-SECTION_IDATA+VADDR_IDATA+IMAGE_BASE]           ;00001027  FF153C304000
reloc3 equ $-4
push edx                        ;0000102D  52
push edx                        ;0000102E  52
test eax,eax                    ;0000102F  85C0
jz .l1                          ;00001031  74E2
mov dword [byte esp+0xc],0x0         ;00001033  C744240C00000000
mov dword [byte esp+0x8], World_str-SECTION_RDATA+VADDR_RDATA+IMAGE_BASE    ;0000103B  C744240817204000
reloc4 equ $-4
mov dword [byte esp+0x4], HelloWorld_str-SECTION_RDATA+VADDR_RDATA+IMAGE_BASE    ;00001043  C74424041E204000
reloc5 equ $-4
mov dword [esp],0x0             ;0000104B  C7042400000000
call eax                        ;00001052  FFD0  ; MessageBoxA.
sub esp,byte +0x10              ;00001054  83EC10
.l3:
test eax,eax                    ;00001057  85C0
setz al                         ;00001059  0F94C0
movzx eax,al                    ;0000105C  0FB6C0
mov [esp],eax                   ;0000105F  890424
call [dword ExitProcess_addr-SECTION_IDATA+VADDR_IDATA+IMAGE_BASE]           ;00001062  FF1538304000  ; ExitProcess.
reloc6 equ $-4

aa $$+0x0468
dd -1, 0  ; !! Why?
aa $$+0x0470
dd -1, 0  ; !! Why?
aa $$+0x0478
SECTION_TEXT_end:
times 0x200-($-SECTION_TEXT) db 0
SECTION_TEXT_end_aligned:

SECTION_RDATA:
VADDR_RDATA equ 0x2000
aa $$+0x0600
user32_dll_str: db 'user32.dll', 0
aa $$+0x060b
MessageBoxA_str: db 'MessageBoxA', 0
aa $$+0x0617
World_str: db 'World!', 0
aa $$+0x061e
HelloWorld_str: db 'Hello,', 10, 'World!', 0
aa $$+0x062c
SECTION_RDATA_end:
times 0x200-($-SECTION_RDATA) db 0
SECTION_RDATA_end_aligned:

SECTION_IDATA:
VADDR_IDATA equ 0x3000
IMAGE_IMPORT_DESCRIPTORS:
aa $$+0x0800
.OriginalFirstThunk: dd IMPORTED_SYMBOL_NAMES+(VADDR_IDATA-SECTION_IDATA)
.TimeDateStamp: dd 0
.ForwarderChain: dd 0
.Name: dd kernel32_dll_str+(VADDR_IDATA-SECTION_IDATA)
aa $$+0x0810
.FirstThunk: dd IMPORT_ADDRESS_TABLE+(VADDR_IDATA-SECTION_IDATA)
aa $$+0x0814
dd 0, 0, 0, 0, 0  ; Same fields as above, filled with 0s.
IMAGE_IMPORT_DESCRIPTORS_end0:
IMPORTED_SYMBOL_NAMES:
dd ExitProcess_name+(VADDR_IDATA-SECTION_IDATA)
dd GetProcAddress_name+(VADDR_IDATA-SECTION_IDATA)
aa $$+0x0830
dd LoadLibraryA_name+(VADDR_IDATA-SECTION_IDATA)
dd 0  ; Marks end-of-list.
IMPORT_ADDRESS_TABLE:
aa $$+0x0838
ExitProcess_addr: dd ExitProcess_name+(VADDR_IDATA-SECTION_IDATA)
GetProcAddress_addr: dd GetProcAddress_name+(VADDR_IDATA-SECTION_IDATA)
aa $$+0x0840
LoadLibraryA_addr: dd LoadLibraryA_name+(VADDR_IDATA-SECTION_IDATA)
dd 0  ; Marks end-of-list.
IMPORT_ADDRESS_TABLE_end:
aa $$+0x0848
ExitProcess_name:
dw 0x0163
db 'ExitProcess', 0
aa $$+0x0856
GetProcAddress_name:
dw 0x02b6
db 'GetProcAddress', 0, 0
aa $$+0x0868
LoadLibraryA_name:
dw 0x03d1
db 'LoadLibraryA', 0, 0
aa $$+0x0878
dd 0x00003000  ; !! Why? Nothing points here.
dd 0x00003000  ; !! Why? Nothing points here.
aa $$+0x0880
dd 0x00003000  ; !! Why? Nothing points here.
aa $$+0x0884
kernel32_dll_str: dd 'KERNEL32.dll', 0
aa $$+0x0894
IMAGE_IMPORT_DESCRIPTORS_end:  ; !! Why not earlier, at IMAGE_IMPORT_DESCRIPTORS_end0?
SECTION_IDATA_end:
times 0x200-($-SECTION_IDATA) db 0
SECTION_IDATA_end_aligned:

SECTION_RELOC:
VADDR_RELOC equ 0x4000
RELOC_BLOCKS:
RELOC_BLOCK__0:
aa $$+0x0a00
dd VADDR_TEXT
dd RELOC_BLOCK__0_end-RELOC_BLOCK__0
.relocs:
BASERELOC_HIGHLOW equ 0x3000
dw reloc0-SECTION_TEXT+BASERELOC_HIGHLOW
dw reloc1-SECTION_TEXT+BASERELOC_HIGHLOW
dw reloc2-SECTION_TEXT+BASERELOC_HIGHLOW
dw reloc3-SECTION_TEXT+BASERELOC_HIGHLOW
dw reloc4-SECTION_TEXT+BASERELOC_HIGHLOW
dw reloc5-SECTION_TEXT+BASERELOC_HIGHLOW
dw reloc6-SECTION_TEXT+BASERELOC_HIGHLOW
%if ($-.relocs)&2
dw 0  ; Padding to even number of relocs.
%endif
RELOC_BLOCK__0_end:
aa $$+0x0a18
;dd 0, 0  ; !!! Is this needed? Not part of SECTION_RELOC.
RELOC_BLOCKS_end:
SECTION_RELOC_end:
times 0x200-($-SECTION_RELOC) db 0
SECTION_RELOC_end_aligned:

; __END__
