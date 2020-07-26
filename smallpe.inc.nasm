;
; smallpe.inc.nasm: small (599 bytes), flexible and ultraportable Win32 PE .exe
;
; Compile: nasm -O0 -f bin -o prog.exe prog.nasm
;
; Runtime compatibility: The generated .exe works on Windows NT 3.1--Windows
; 10, tested on Windows NT 3.1, Windows 95, Windows XP, Windows 10 and Wine 5.0.
;
; Example prog.exe (599 bytes) which just exits:
;
;   %include "smallpe.inc.nasm"
;   _start:
;   push byte 0  ; EXIT_SUCCESS == 0.
;   ; For NASM >= 2.03, you can just use: kcall GetStdHandle
;   kcall ExitProcess, 'ExitProcess'
;   endpe
;
; It's hard to write any shorter code after _start, because the program
; should exit cleanly.
;
; Example prog.exe which prints hello-world and exits:
;
;   _start:
;   push strict byte -11  ; STD_OUTPUT_HANDLE.
;   ; For NASM >= 2.03, you can just use: kcall GetStdHandle
;   kcall GetStdHandle, 'GetStdHandle'
;   ;push eax  ; Save stdout handle.
;   push eax  ; Value is arbitrary, we allocate an output variable on the stack.
;   mov ebx, esp
;   push strict byte 0  ; Argument 5: lpOverlapped = 0.
;   push ebx  ; Argument 4: Address of the output variable.
;   push strict byte message_end-message  ; Argument 3: message size.
;   push strict dword message  ; Argument 2: message.
;   push eax  ; if it was saved, strict dword [esp+20]  ; Argument 1: Stdout handle.
;   kcall WriteFile, 'WriteFile'
;   push strict byte 0  ; EXIT_SUCCESS == 0.
;   kcall ExitProcess, 'ExitProcess'
;   message:
;   db 'Hello, World!', 13, 10
;   message_end:
;   endpe
;
; Minimum version of NASM needed: 0.99.06 (2007-11-04).
;
; Call functions in KERNEL32.DLL using the `kcall TheFunctionName' syntax.
; Other Win32 DLLs (e.g. USER32.DLL and GDI32.DLL) are not supported
; directly. If you need them, load them with LoadLibraryA, and then get
; address of a function with GetProcAddress.
;
; Your code will start at offset 512 in the .exe file, you can disassemble
; it with:
;
;   $ ndisasm -b 32 -e 0x200 -o 0x1000 prog.exe
;

; Asserts that we are at offset %1 from the beginning of the input file
%macro __ASSERT_AT_VERBOSE__ 1
times $-(%1) times 0 nop
times (%1)-$ times 0 nop
%endmacro

bits 32
cpu 386

; The user can %define these to override the defaults.
; !! Do macro expansion on IMAGE_BASE now, and save the result.
%ifdef IMAGE_BASE
__IMAGE_BASE__ equ IMAGE_BASE
%else
__IMAGE_BASE__ equ 0x00400000  ; Variable.
%endif
%ifndef AFTER_LAST_SECTION_ALIGNMENT
AFTER_LAST_SECTION_ALIGNMENT equ 1  ; Set it to 512 to get an 1024-byte .exe.
%endif
IMAGE_SUBSYSTEM_WINDOWS_GUI equ 2  ; gcc -mwindows
IMAGE_SUBSYSTEM_WINDOWS_CUI equ 3  ; gcc -mconsole
%ifndef IMAGE_SUBSYSTEM
IMAGE_SUBSYSTEM equ IMAGE_SUBSYSTEM_WINDOWS_CUI
%endif
%ifndef STUB_SIZE
STUB_SIZE equ 0x60
%endif
%ifndef VADDR_TEXT
VADDR_TEXT equ (0x120+(STUB_SIZE)+4095)&~4095  ; 0x1000 by default.
%endif
%if VADDR_TEXT<0x120+(STUB_SIZE)
; Wine 5.0 doesn't care, but Windows NT 3.1, Windows 95 and Windows XP do.
%error 'VADDR_TEXT too small, must be at least 0x120+STUB_SIZE'
%endif

section header align=1 valign=1 vstart=__IMAGE_BASE__
_HEADER:
section text   align=1 valign=1 follows=header vstart=(__IMAGE_BASE__+VADDR_TEXT)
_TEXT:
section import align=1 valign=1 follows=text vfollows=text  ; Import address table.
_IMPORT:
section name   align=1 valign=1 follows=import vfollows=import
_NAME:
section bss    align=1 follows=name nobits
_BSS:

; If the user forgets to call it at the end, NASM will report this error:
;    error: symbol `__PLEASE_CALL_endpe__' undefined
;
; !! Add warning if code is added after endpe.
%macro endpe 1
  %ifdef __PLEASE_CALL_endpe__
  %error 'endpe called twice'
  %else
  %define __PLEASE_CALL_endpe__ __PLEASE_CALL_endpe__
  __PLEASE_CALL_endpe__ equ 0
  __ENTRY_POINT__ equ (%1)
  section text
  _TEXT_end:
  section bss
  _BSS_end:
  section header
  times ($$-$)&511 db 0
  _HEADER_end_aligned:
  section import
  dd 0  ; Marks end-of-list.
  IMPORT_ADDRESS_TABLE_end:
  _IMPORT_end:
  section name
  dd 0  ; Why is this needed? A dw is not enough.
  _NAME_end:
  times (-($-$$+_TEXT_end-_TEXT+_IMPORT_end-_IMPORT) %% AFTER_LAST_SECTION_ALIGNMENT+AFTER_LAST_SECTION_ALIGNMENT)%AFTER_LAST_SECTION_ALIGNMENT db 0
  _NAME_end_aligned:
  %endif
%endmacro
%macro endpe 0
  %ifdef __ENTRY_POINT__
  endpe __ENTRY_POINT__
  %else
  endpe _start
  %endif
%endmacro

section header
IMAGE_DOS_HEADER:
__ASSERT_AT_VERBOSE__ $$+0
; https://github.com/pts/pts-nasm-fullprog/blob/master/pe_stub3.nasm
.mz_sigature: db 'MZ'  ; Signature.
.image_size_lo: dw (IMAGE_NT_HEADERS-IMAGE_DOS_HEADER)&511  ; Image size low 9 bits.
.image_size_hi: dw (IMAGE_NT_HEADERS-IMAGE_DOS_HEADER+511)>>9  ; Image size high bits, rounded up.
dw 0  ; Relocation count.
dw 0  ; Paragraph (16 byte) count of header. Points to the top of the file.
%if (STUB_SIZE)<0x340
dw (0x400-(IMAGE_NT_HEADERS-IMAGE_DOS_HEADER))>>4  ; Reserve 0x340 bytes of extra memory for stack.
%else
dw 0
%endif
dw 0xffff  ; Paragraph count of maximum required memory.
dw 0  ; Stack segment (ss) base.
dw 0x400  ; Stack pointer (sp).
dw 0  ; No file checksum.
dw .stub_start  ; Instruction pointer (ip).
dw 0  ; Code segment (cs) base.
; We reuse the final 4 bytes of the .exe header (dw relocation_table_ofs,
; overlay_number) for code.
.stub_msg: db 'This program cannot be run in DOS m$'
dd IMAGE_NT_HEADERS-_HEADER  ; At offset 60. Points to the "PE\0\0" header.
.stub_msg2: db 'ode.', 13, 10, '$'
times 6 db 0  ; Padding between stub text and code. Can be reused.
.stub_start:
push ss
pop ds
mov ah, 9  ; WRITE_DOLLAR_STDOUT.
db 0xba  ; 16-bit mov dx, ...
dw .stub_msg
int 0x21
db 0xba  ; 16-bit mov dx, ...
dw .stub_msg2
int 0x21
db 0xb8  ; 16-bit mov ax, ...
dw 0x4c01  ; EXIT(1).
int 0x21
__ASSERT_AT_VERBOSE__ $$+0x60
times (STUB_SIZE)-($-$$) db 'S'
times ($$-$)&15 db 0

IMAGE_NT_HEADERS:
db 'PE', 0, 0

IMAGE_FILE_HEADER:
Machine: dw 0x14c  ; IMAGE_FILE_MACHINE_I386
NumberOfSections: dw (IMAGE_SECTION_HEADER_end-IMAGE_SECTION_HEADER)/40
TimeDateStamp: dd 0+0*__PLEASE_CALL_endpe__
PointerToSymbolTable: dd 0
NumberOfSymbols: dd 0
SizeOfOptionalHeader: dw IMAGE_OPTIONAL_HEADER32_end-IMAGE_OPTIONAL_HEADER32
dw 0x030f

IMAGE_OPTIONAL_HEADER32:
Magic: dw 0x10b  ; IMAGE_NT_OPTIONAL_HDR32_MAGIC
MajorLinkerVersion: db 6
MinorLinkerVersion: db 0
SizeOfCode: dd 0x00000000
SizeOfInitializedData: dd 0x00000000
SizeOfUninitializedData: dd 0x00000000
AddressOfEntryPoint: dd __ENTRY_POINT__-__IMAGE_BASE__  ; Also called starting address.
BaseOfCode: dd VADDR_TEXT
BaseOfData: dd VADDR_TEXT
ImageBase: dd _HEADER
SectionAlignment: dd 0x1000  ; Single allowed value for Windows XP.
FileAlignment: dd 0x200  ; Minimum value for Windows NT 3.1.
MajorOperatingSystemVersion: dw 4
MinorOperatingSystemVersion: dw 0
MajorImageVersion: dw 0
MinorImageVersion: dw 0
MajorSubsystemVersion: dw 3   ; Windows NT 3.1.
MinorSubsystemVersion: dw 10  ; Windows NT 3.1.
Win32VersionValue: dd 0
SizeOfImage: dd VADDR_TEXT+(_TEXT_end-_TEXT+_IMPORT_end-_IMPORT+_NAME_end-_NAME+_BSS_end-_BSS)  ; Wine requires >0x1000.
SizeOfHeaders: dd _HEADER_end_aligned-_HEADER
CheckSum: dd 0  ; Not checked.
Subsystem: dw IMAGE_SUBSYSTEM
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
.VirtualAddress: dd IMAGE_IMPORT_DESCRIPTORS-__IMAGE_BASE__
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
.VirtualAddress: dd IMPORT_ADDRESS_TABLE-__IMAGE_BASE__
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

IMAGE_SECTION_HEADER:
IMAGE_SECTION_HEADER__0:
.Name: db '.text'
times 8-($-.Name) db 0
.VirtualSize: dd (_TEXT_end-_TEXT)+(_IMPORT_end-_IMPORT)+(_NAME_end-_NAME)+(_BSS_end-_BSS)
.VirtualAddress: dd VADDR_TEXT
.SizeOfRawData: dd (_TEXT_end-_TEXT)+(_IMPORT_end-_IMPORT)+(_NAME_end_aligned-_NAME)
.PointerToRawData: dd _HEADER_end_aligned-_HEADER
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
; Now we are at file offset 0x120+(STUB_SIZE...align16).

section import
IMAGE_IMPORT_DESCRIPTORS:
IMAGE_IMPORT_DESCRIPTOR_0:
.OriginalFirstThunk: dd IMPORT_ADDRESS_TABLE-__IMAGE_BASE__
.TimeDateStamp: dd 0
.ForwarderChain: dd 0
.Name: dd NAME_KERNEL32_DLL-__IMAGE_BASE__
.FirstThunk: dd IMPORT_ADDRESS_TABLE-__IMAGE_BASE__
IMAGE_IMPORT_DESCRIPTOR_1:  ; Last Import directory table, marks end-of-list.
dd 0, 0, 0, 0, 0  ; Same fields as above, filled with 0s.
IMAGE_IMPORT_DESCRIPTORS_end:

IMPORT_ADDRESS_TABLE:  ; Import address table. Modified by the PE loader before jumping to _entry.

section name
NAME_KERNEL32_DLL: db 'kernel32.dll', 0

section text

; Calls the named function in KERNEL32.DLL.
;
; NASM doesn't verify at compile time whether the function exists in
; KERNEL32.DLL.
;
; Usage: kcall TheFunctionName, 'TheFunctionName'
;   This works in NASM versions earlier than 2.03, e.g. 0.99.06.
; Usage: kcall TheFunctionName
;   This needs NASM version >= 2.03 (released 2008-06-10).
%macro kcall 2
; We could use `%iftoken %1' in NASM >= 2.02. We don't bother.
%ifstr %2  ; SUXX: It's also true for 'foo'+4.
%ifndef __imp__%1  ; Extend the import and name sections only once.
%define __imp__%1 __imp__%1
[section import]
__imp__%1: dd __name__%1-__IMAGE_BASE__
[section name]
__name__%1:
.Hint: dw 0
.Name: db %2, 0
__SECT__  ; Back to the previous section when the macro was called.
%endif
call [__imp__%1]
%else
%error 'Argument 2 of kcall must be a a quoted string.'
%endif
%endmacro

; Usage: kcall ExitProcess
; This needs NASM version >= 2.03 (released 2008-06-10).
%macro kcall 1
%iftoken %1  ; This needs NASM >= 2.03.
%ifid %1
%defstr __dllfuncname__ %1  ; This needs NASM >= 2.03.
kcall %1, __dllfuncname__
%undef __dllfuncname__
%else
%error 'Argument of kcall must be an identifier.'
%endif
%else
%error 'Argument of kcall must be a token.'
%endif
%endmacro

; __END__
