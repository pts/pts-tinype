;
; hh4t.nasm: a shortening of the NASM reimplementation of hh3tg.golden.exe
; by pts@fazekas.hu at Fri Jul 31 23:43:28 CEST 2020
;
; Compile: nasm -O0 -f bin -o hh4t.exe hh4t.nasm
;
; It works on Win32s, Windows NT 3.1--Windows 10, tested on Windows NT 3.1,
; Windows 95, Windows XP and Wine 5.0.
;
; It could be optimized further by directly importing user32.dll (instead of
; with LoadLibraryA).
;

bits 32
cpu 386

; Asserts that we are at offset %1 from the beginning of the input file
%macro aa 1
times $-(%1) times 0 nop
times (%1)-$ times 0 nop
%endmacro

%assign VADDR_PAGE -0x1000
%macro new_page 1
%assign VADDR_PAGE VADDR_PAGE+0x1000
%1 equ VADDR_PAGE
%assign SECTION_PAGE_FOFS $-$$
%endmacro

IMAGE_BASE equ 0x400000
BSS_SIZE equ 0

SECTION_HEADER:
new_page VADDR_HEADER
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

IMAGE_NT_HEADERS:
aa $$+0x40
db 'PE', 0, 0
IMAGE_FILE_HEADER:
Machine: dw 0x14c  ; IMAGE_FILE_MACHINE_I386
NumberOfSections: dw (IMAGE_SECTION_HEADER_end-IMAGE_SECTION_HEADER)/40
DateTimeStamp: dd 0
PointerToSymbolTable: dd 0
NumberOfSymbols: dd 0
SizeOfOptionalHeader: dw IMAGE_OPTIONAL_HEADER32_end-IMAGE_OPTIONAL_HEADER32
IMAGE_FILE_RELOCS_STRIPPED equ 1
Characteristics: dw 0x030e  ; Doesn't have IMAGE_FILE_RELOCS_STRIPPED.

IMAGE_OPTIONAL_HEADER32:
Magic: dw 0x10b  ; IMAGE_NT_OPTIONAL_HDR32_MAGIC
MajorLinkerVersion: db 6
MinorLinkerVersion: db 0
SizeOfCode: dd 0
SizeOfInitializedData: dd 0
SizeOfUninitialiedData: dd 0
AddressOfEntryPoint: dd _start+(VADDR_TEXT-SECTION_TEXT)  ; Also called starting address.
BaseOfCode: dd VADDR_TEXT
BaseOfData: dd VADDR_TEXT  ; 0 also works.
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
SizeOfImage: dd VADDR_END+EXTRA_BSS_SIZE+BSS_SIZE
SizeOfHeaders: dd SECTION_HEADER_end_aligned
CheckSum: dd 0  ; Most loaders ignore it.
Subsystem: dw 2  ; IMAGE_SUBSYSTEM_WINDOWS_GUI; gcc -mwindows
IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE equ 0x40
dw 0  ; Changed back from IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE.
SizeOfStackReserve: dd 0x00100000
SizeOfStackCommit: dd 0x00001000
SizeOfHeapReserve: dd 0x100000  ; Why not 0?
SizeOfHeapCommit: dd 0x1000  ; Why not 0?
LoaderFlags: dd 0
NumberOfRvaAndSizes: dd (IMAGE_DATA_DIRECTORY_end-IMAGE_DATA_DIRECTORY)/8
IMAGE_DATA_DIRECTORY:
IMAGE_DIRECTORY_ENTRY_EXPORT:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_IMPORT:
.VirtualAddress: dd IMAGE_IMPORT_DESCRIPTORS+(VADDR_IDATA-SECTION_IDATA)
.Size: dd IMAGE_IMPORT_DESCRIPTORS_end-IMAGE_IMPORT_DESCRIPTORS
IMAGE_DIRECTORY_ENTRY_RESOURCE:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_EXCEPTION:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_SECURITY:
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_BASERELOC:
.VirtualAddress: dd RELOC_BLOCKS+(VADDR_HEADER-SECTION_HEADER)
.Size: dd RELOC_BLOCKS_end-RELOC_BLOCKS
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
; !! Can we set it to 0, and make the header shorter?
.VirtualAddress: dd IMPORT_ADDRESS_TABLE+(VADDR_IDATA-SECTION_IDATA)
.Size: dd IMPORT_ADDRESS_TABLE_end-IMPORT_ADDRESS_TABLE
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
times (.Name-$)&7 db 0
.VirtualSize: dd SECTION_TEXT_end-SECTION_TEXT+EXTRA_BSS_SIZE+BSS_SIZE
.VirtualAddress: dd VADDR_TEXT
.SizeOfRawData: dd SECTION_TEXT_end-SECTION_TEXT
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
IMAGE_SCN_ALIGN_4BYTES equ 0x00300000
IMAGE_SCN_MEM_DISCARDABLE equ 0x02000000
.Characteristics: dd IMAGE_SCN_CNT_CODE|IMAGE_SCN_CNT_INITIALIZED_DATA|IMAGE_SCN_MEM_EXECUTE|IMAGE_SCN_MEM_READ|IMAGE_SCN_MEM_WRITE

IMAGE_SECTION_HEADER_end:

kernel32_dll_str: db 'kernel32.dll', 0
LoadLibraryA_name: db 0, 0, 'LoadLibraryA', 0
GetProcAddress_name: db 0, 0, 'GetProcAddress', 0
ExitProcess_name: db 0, 0, 'ExitProcess', 0  ; !! Merge 3 NULs to 2, everywhere.

user32_dll_str: db 'user32.dll', 0
MessageBoxA_str: db 'MessageBoxA', 0
HelloWorld_str: db 'Hello,', 10
World_str: db 'World!', 0

; Without these relocation blocks, Win32s wouldn't be able to run the .exe.
; They are ignored by Wine, Windows NT, Windows 95 and Windows XP+.
RELOC_BLOCKS:
RELOC_BLOCK__0:
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
%if ($-.relocs)&2  ; !! Is this padding really needed? Which Windows version breaks without it?
dw 0  ; Padding to even number of relocs.
%endif
RELOC_BLOCK__0_end:
RELOC_BLOCKS_end:

SECTION_HEADER_end:
times 0x200-($-SECTION_HEADER) db 'R'
SECTION_HEADER_end_aligned:

SECTION_TEXT:
SECTION_RDATA:
SECTION_IDATA:
SECTION_RELOC:
new_page VADDR_TEXT
VADDR_RDATA equ VADDR_TEXT
VADDR_IDATA equ VADDR_TEXT
VADDR_RELOC equ VADDR_TEXT
_start:
push strict dword user32_dll_str-SECTION_HEADER+VADDR_HEADER+IMAGE_BASE
reloc0 equ $-4
call [dword LoadLibraryA_addr-SECTION_IDATA+VADDR_IDATA+IMAGE_BASE]  ; Returns handle in eax.
reloc1 equ $-4
test eax, eax
jz error
push strict dword MessageBoxA_str-SECTION_HEADER+VADDR_HEADER+IMAGE_BASE
reloc2 equ $-4
push eax
call [dword GetProcAddress_addr-SECTION_IDATA+VADDR_IDATA+IMAGE_BASE]  ; Returns &MessageBox in eax.
reloc3 equ $-4
test eax, eax
jz error
xor ebx, ebx
push ebx  ; uType.
push strict dword World_str-SECTION_HEADER+VADDR_HEADER+IMAGE_BASE  ; lpCaption.
reloc4 equ $-4
push strict dword HelloWorld_str-SECTION_HEADER+VADDR_HEADER+IMAGE_BASE  ; lpText.
reloc5 equ $-4
push ebx  ; hWnd.
call eax  ; MessageBoxA.
push byte +0  ; EXIT_SUCCESS.
jmp strict short do_exit
error:
push dword +1  ; EXIT_FAILURE.
do_exit:
call [dword ExitProcess_addr-SECTION_IDATA+VADDR_IDATA+IMAGE_BASE]
reloc6 equ $-4

IMPORT_ADDRESS_TABLE:
LoadLibraryA_addr: dd LoadLibraryA_name+(VADDR_HEADER-SECTION_HEADER)
GetProcAddress_addr: dd GetProcAddress_name+(VADDR_HEADER-SECTION_HEADER)
ExitProcess_addr: dd ExitProcess_name+(VADDR_HEADER-SECTION_HEADER)
dd 0  ; Marks end-of-list.
IMPORT_ADDRESS_TABLE_end:

IMAGE_IMPORT_DESCRIPTORS:
.OriginalFirstThunk: dd IMPORT_ADDRESS_TABLE+(VADDR_IDATA-SECTION_IDATA)
.TimeDateStamp: dd 0
.ForwarderChain: dd 0
.Name: dd kernel32_dll_str+(VADDR_HEADER-SECTION_HEADER)
.FirstThunk: dd IMPORT_ADDRESS_TABLE+(VADDR_IDATA-SECTION_IDATA)
;dd 0, 0, 0, 0, 0  ; Same fields as above, filled with 0s.
EXTRA_BSS_SIZE equ 4*5  ; For the end-of-list bytes above.
;EXTRA_BSS_SIZE equ 0
IMAGE_IMPORT_DESCRIPTORS_end equ $+EXTRA_BSS_SIZE

SECTION_TEXT_end:

VADDR_END equ $-(SECTION_PAGE_FOFS+$$)+VADDR_PAGE

; __END__
