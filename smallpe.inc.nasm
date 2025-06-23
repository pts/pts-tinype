;
; smallpe.inc.nasm: small (548 bytes), flexible and ultraportable Win32 PE .exe
; by pts@fazekas.hu on 2020-07-25
;
; Compile: nasm -O0 -f bin -o prog.exe prog.nasm
;
; Runtime compatibility: The generated .exe works on Windows NT 3.1--Windows
; 10, tested on Windows NT 3.1, Windows 95, Windows XP, Windows 7, Windows 10
; and Wine 5.0.
;
; Example prog.exe (548 bytes) which just exits successfully:
;
;   %include "smallpe.inc.nasm"
;   _start:
;   endpe  ; A call to ExitProcess (with EXIT_SUCCESS == 0) is auto-added.
;
; It's hard to write any shorter code after _start, because the program
; should exit cleanly.
;
; Example prog.exe which prints hello-world and exits:
;
;   %include "smallpe.inc.nasm"
;   _start:
;   push strict byte -11  ; STD_OUTPUT_HANDLE.
;   kcall GetStdHandle  ; Calls function in KERNEL32.DLL.
;   ;push eax  ; Save stdout handle.
;   push eax  ; Value is arbitrary, we allocate an output variable on the stack.
;   mov ebx, esp
;   push strict byte 0  ; Argument 5: lpOverlapped = 0.
;   push ebx  ; Argument 4: Address of the output variable.
;   push strict byte message_end-message  ; Argument 3: message size.
;   push strict dword message  ; Argument 2: message.
;   push eax  ; if it was saved, strict dword [esp+20]  ; Argument 1: Stdout handle.
;   kcall WriteFile
;   ; A call to ExitProcess (with EXIT_SUCCESS == 0) is auto-added.
;   section rodata  ; Optional, but makes the .exe output smaller.
;   message:
;   db 'Hello, World!', 13, 10
;   message_end:
;   endpe
;
; Minimum version of NASM needed: 0.98.39 (2005-01-20).
;
; Call functions in KERNEL32.DLL using the `kcall TheFunctionName' syntax.
; Other Win32 DLLs (e.g. USER32.DLL and GDI32.DLL) are not supported
; directly. If you need them, load them with `kcall LoadLibraryA', and then
; get address of a function with `kcall GetProcAddress'.
;
; If `section rodata' (which includes the function names in all kcalls) is
; short, then your code will start at offset 512 in the .exe file, you can
; disassemble it with:
;
;   $ ndisasm -b 32 -e 0x200 -o 0x1000 prog.exe
;

bits 32
cpu 386

; The user can %define these to override the defaults.
%ifdef  __IMAGE_BASE__
%assign __IMAGE_BASE__ __IMAGE_BASE__
%else
%assign __IMAGE_BASE__ 0x00400000
%endif
$__IMAGE_BASE__ equ __IMAGE_BASE__

IMAGE_SUBSYSTEM_WINDOWS_GUI equ 2  ; gcc -mwindows
IMAGE_SUBSYSTEM_WINDOWS_CUI equ 3  ; gcc -mconsole
%ifdef  IMAGE_SUBSYSTEM
%assign IMAGE_SUBSYSTEM IMAGE_SUBSYSTEM
%else
%define IMAGE_SUBSYSTEM IMAGE_SUBSYSTEM_WINDOWS_CUI
%endif
$IMAGE_SUBSYSTEM equ IMAGE_SUBSYSTEM

section stub     align=1 valign=1 vstart=__IMAGE_BASE__  ; The user can replace it with the DOS stub. 64-byte DOS stub by default.
_STUB:
section stubx    align=1 valign=1 follows=stub vfollows=stub  ; Extra stub bytes by the user. Usually empty.
_STUBX:
section peheader align=1 valign=1 follows=stubx vfollows=stubx  ; Starts with the PE header, ends with names. The user shouldn't add anything here.
_PEHEADER:
section rodata   align=1 valign=1 follows=peheader vfollows=peheader  ; The user can populate it with read-only (no write, no execute) data. May overflow to text, restrictions may not be enforced.
_RODATA:
section text     align=1 valign=1 follows=rodata vstart=__PLEASE_CALL_endpe__  ; The user should populate it with code or data (read, write, execute).
_TEXT:
section iat      align=1 valign=1 follows=text vfollows=text  ; Contains the import address table. The user shouldn't add anthing here.
_IAT:
section import   align=1 valign=1 follows=iat vfollows=iat  ; Contains the import descriptor. Must be directly in front of bss. The user shouldn't add anthing here.
_IMPORT:
section bss      align=1 follows=import nobits  ; The user can populate it with uninitialized data (e.g. with resb).
_BSS:
section endpe    align=1 follows=bss nobits  ; Sentinel section, the user must leave it empty.

section peheader

IMAGE_NT_HEADERS:
db 'PE', 0, 0

IMAGE_FILE_HEADER:
Machine: dw 0x14c  ; IMAGE_FILE_MACHINE_I386
NumberOfSections: dw (IMAGE_SECTION_HEADER_end-IMAGE_SECTION_HEADER)/40
TimeDateStamp: dd 0+0*__PLEASE_CALL_endpe__
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
AddressOfEntryPoint: dd __ENTRY_POINT__-__IMAGE_BASE__  ; Also called starting address.
BaseOfCode: dd __RVA_TEXT__
BaseOfData: dd __RVA_TEXT__
ImageBase: dd __IMAGE_BASE__
SectionAlignment: dd 0x1000  ; Single allowed value for Windows XP.
FileAlignment: dd 0x200  ; Minimum value for Windows NT 3.1.
MajorOperatingSystemVersion: dw 4
MinorOperatingSystemVersion: dw 0
MajorImageVersion: dw 0
MinorImageVersion: dw 0
MajorSubsystemVersion: dw 3   ; Windows NT 3.1.
MinorSubsystemVersion: dw 10  ; Windows NT 3.1.
Win32VersionValue: dd 0
SizeOfImage: dd __IMAGE_SIZE__
SizeOfHeaders: dd __IMAGE_SIZE_UPTO_TEXT__-(_RODATA_end-_RODATA_before_padding)
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
IMAGE_DIRECTORY_ENTRY_EXPORT: ; 0.
.VirtualAddress: dd 0
.Size: dd 0
IMAGE_DIRECTORY_ENTRY_IMPORT:  ; 1. Import directory.
.VirtualAddress: dd IMAGE_IMPORT_DESCRIPTORS-__IMAGE_BASE__
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
.VirtualAddress: dd IMPORT_ADDRESS_TABLE-__IMAGE_BASE__
.Size: dd IMPORT_ADDRESS_TABLE_end-IMPORT_ADDRESS_TABLE
; TODO(pts): Remove more above, like in hh2d.nasm.
; These entries are not needed.
;IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT:  ; 13.
;.VirtualAddress: dd 0
;.Size: dd 0
;IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR:  ; 14. Nonzero for .NET .exe.
;.VirtualAddress: dd 0
;.Size: dd 0
;IMAGE_DIRECTORY_ENTRY_RESERVED:  ; 15.
;.VirtualAddress: dd 0
;.Size: dd 0

IMAGE_DATA_DIRECTORY_end:
IMAGE_OPTIONAL_HEADER32_end:

IMAGE_SECTION_HEADER:
IMAGE_SECTION_HEADER__0:
.Name: db '.text'
times ($$-$)&7 db 0
.VirtualSize: dd __IMAGE_SIZE__-__RVA_TEXT__
.VirtualAddress: dd __RVA_TEXT__
.SizeOfRawData: dd __IMAGE_SIZE_UPTO_BSS__-__RVA_TEXT__  ; Byte size in file.
.PointerToRawData: dd __IMAGE_SIZE_UPTO_TEXT__&~0x1ff  ; File offset.
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
;db 0  ; We don't add a double trailing NUL to enforce even name alignment, because the name has even length

section import
; Windows 95 requires this to be part of a section; Windows NT 3.1 and
; Windows XP work if this is in the header.
IMAGE_IMPORT_DESCRIPTORS:
IMAGE_IMPORT_DESCRIPTOR_0:
.OriginalFirstThunk: dd IMPORT_ADDRESS_TABLE-__IMAGE_BASE__
.TimeDateStamp: dd 0
.ForwarderChain: dd 0
.Name: dd NAME_KERNEL32_DLL-__IMAGE_BASE__
.FirstThunk: dd IMPORT_ADDRESS_TABLE-__IMAGE_BASE__
IMAGE_IMPORT_DESCRIPTOR_1:  ; Last Import directory table, marks end-of-list.
;dd 0, 0, 0, 0, 0  ; Same fields as above, filled with 0s.
; For the end-of-list bytes above + one more all-0 descriptor, for
; Windows 95 4.00.950 C HeapAlloc(...) and after-boot compatibility.
IMAGE_IMPORT_DESCRIPTORS_BSS_SIZE equ (4*5)*3
_IMPORT_end:
IMAGE_IMPORT_DESCRIPTORS_end equ $+IMAGE_IMPORT_DESCRIPTORS_BSS_SIZE
section bss
resb IMAGE_IMPORT_DESCRIPTORS_BSS_SIZE

section iat
; Because of the modification, this mustn't start earlier than __RVA_TEXT__
IMPORT_ADDRESS_TABLE:  ; Import address table. Modified by the PE loader before jumping to __ENTRY__POINT__.

; Calls the named function in KERNEL32.DLL.
;
; NASM doesn't verify at compile time whether the function exists in
; KERNEL32.DLL.
;
; Usage: kcall 'TheFunctionName'  ; Recommended.
;   This works in NASM version >= 0.98.39 (released 2005-01-20).
; Usage: kcall TheFunctionName
;   This works in NASM version >= 0.98.39 (released 2005-01-20) for the ~50
;   most commonly used functions in KERNEL32.DLL, and it works in all
;   functions with NASM version >= 2.03 (released 2008-06-10).
; Usage: kcall __imp__TheFunctionName@ArgBytes, 'TheFunctionName'
;   This works in NASM version >= 0.98.39 (released 2005-01-20).
;   The actual symbol name (%1) doesn't matter (e.g. GCC, OpenWatcom C
;   compiler and TCC emit __imp__WriteFile@20), but if you use different names
;   for the same library function (%2), then the same function name name (%2)
;   will be emitted multiple times to your .exe.
%macro kcall 2
; We could use `%iftoken %1' in NASM >= 2.02. We don't bother.
%ifstr %2  ; SUXX: It's also true for 'foo'+4.
%ifndef %1  ; Extend the import and name sections only once.
%define %1 %1
[section iat]
; Contribute an entry to IMPORT_ADDRESS_TABLE.
%1: dd __name__%1-__IMAGE_BASE__
[section peheader]
__name__%1:
.Hint: dw 0
.Name: db %2, 0
; OpenWatcom wlink(1) would add an extra 0 for names with an even length, to
; enforce even name alignment. But that's not needed, so we don't add it.
%if 0 && ($-.Name)&1
  db 0
%endif
__SECT__  ; Back to the previous section when the macro was called.
%endif
call [%1]
%else
%error 'Argument 2 of kcall must be a a quoted string.'
%endif
%endmacro

; Helper macro deftok_compat (to be used in kcall/1).
%if __NASM_MAJOR__>2 || (__NASM_MAJOR__==2 && __NASM_MINOR__>=8)
%macro deftok_compat 3
%deftok %1 %3  ; Available in NASM >= 2.08.
%xdefine %1 %2 %+ %1
%endmacro
%else
%macro deftok_compat 3
%strlen %$len %3
%assign %$i 1
%define %1 %2
%rep %$len
%substr %$c %3 %$i
%assign %$i %$i+1
%if %$c=''  ; Not needed, just for symmetry.
%elif %$c='a'
%xdefine %1 %1 %+ a
%elif %$c='b'
%xdefine %1 %1 %+ b
%elif %$c='c'
%xdefine %1 %1 %+ c
%elif %$c='d'
%xdefine %1 %1 %+ d
%elif %$c='e'
%xdefine %1 %1 %+ e
%elif %$c='f'
%xdefine %1 %1 %+ f
%elif %$c='g'
%xdefine %1 %1 %+ g
%elif %$c='h'
%xdefine %1 %1 %+ h
%elif %$c='i'
%xdefine %1 %1 %+ i
%elif %$c='j'
%xdefine %1 %1 %+ j
%elif %$c='k'
%xdefine %1 %1 %+ k
%elif %$c='l'
%xdefine %1 %1 %+ l
%elif %$c='m'
%xdefine %1 %1 %+ m
%elif %$c='n'
%xdefine %1 %1 %+ n
%elif %$c='o'
%xdefine %1 %1 %+ o
%elif %$c='p'
%xdefine %1 %1 %+ p
%elif %$c='q'
%xdefine %1 %1 %+ q
%elif %$c='r'
%xdefine %1 %1 %+ r
%elif %$c='s'
%xdefine %1 %1 %+ s
%elif %$c='t'
%xdefine %1 %1 %+ t
%elif %$c='u'
%xdefine %1 %1 %+ u
%elif %$c='v'
%xdefine %1 %1 %+ v
%elif %$c='w'
%xdefine %1 %1 %+ w
%elif %$c='x'
%xdefine %1 %1 %+ x
%elif %$c='y'
%xdefine %1 %1 %+ y
%elif %$c='z'
%xdefine %1 %1 %+ z
%elif %$c='A'
%xdefine %1 %1 %+ A
%elif %$c='B'
%xdefine %1 %1 %+ B
%elif %$c='C'
%xdefine %1 %1 %+ C
%elif %$c='D'
%xdefine %1 %1 %+ D
%elif %$c='E'
%xdefine %1 %1 %+ E
%elif %$c='F'
%xdefine %1 %1 %+ F
%elif %$c='G'
%xdefine %1 %1 %+ G
%elif %$c='H'
%xdefine %1 %1 %+ H
%elif %$c='I'
%xdefine %1 %1 %+ I
%elif %$c='J'
%xdefine %1 %1 %+ J
%elif %$c='K'
%xdefine %1 %1 %+ K
%elif %$c='L'
%xdefine %1 %1 %+ L
%elif %$c='M'
%xdefine %1 %1 %+ M
%elif %$c='N'
%xdefine %1 %1 %+ N
%elif %$c='O'
%xdefine %1 %1 %+ O
%elif %$c='P'
%xdefine %1 %1 %+ P
%elif %$c='Q'
%xdefine %1 %1 %+ Q
%elif %$c='R'
%xdefine %1 %1 %+ R
%elif %$c='S'
%xdefine %1 %1 %+ S
%elif %$c='T'
%xdefine %1 %1 %+ T
%elif %$c='U'
%xdefine %1 %1 %+ U
%elif %$c='V'
%xdefine %1 %1 %+ V
%elif %$c='W'
%xdefine %1 %1 %+ W
%elif %$c='X'
%xdefine %1 %1 %+ X
%elif %$c='Y'
%xdefine %1 %1 %+ Y
%elif %$c='Z'
%xdefine %1 %1 %+ Z
%elif %$c='0'
%xdefine %1 %1 %+ 0
%elif %$c='1'
%xdefine %1 %1 %+ 1
%elif %$c='2'
%xdefine %1 %1 %+ 2
%elif %$c='3'
%xdefine %1 %1 %+ 3
%elif %$c='4'
%xdefine %1 %1 %+ 4
%elif %$c='5'
%xdefine %1 %1 %+ 5
%elif %$c='6'
%xdefine %1 %1 %+ 6
%elif %$c='7'
%xdefine %1 %1 %+ 7
%elif %$c='8'
%xdefine %1 %1 %+ 8
%elif %$c='9'
%xdefine %1 %1 %+ 9
%elif %$c='_'
%xdefine %1 %1 %+ _
%else
%error invalid deftok character: %$c
%endif
%endrep
%endmacro
%endif

; Helper macro defiftoken28 (to be used in kcall/1).
;
; Defines %1 if %2 is a token. Works in NASM >= 2.08.
; Top-level helper macro to keen the %if...%endif balance in NASM < 2.08.
%macro defiftoken28 2
%iftoken %2  ; Available in NASM >= 2.08.
%define %1
%endif
%endmacro

; Helper macro defiftoken (to be used in kcall/1).
%if __NASM_MAJOR__>2 || (__NASM_MAJOR__==2 && __NASM_MINOR__>=8)
%macro defiftoken 2
defiftoken28 %1, %2
%endmacro
%else
%macro defiftoken 2
%define %1  ; Assume %1 is a token.
%endmacro
%endif

; Macro kcall/1.
;
; Usage: kcall ExitProces
; Usage: kcall 'ExitProcess'
%if __NASM_MAJOR__>2 || (__NASM_MAJOR__==2 && __NASM_MINOR__>=3)
%macro kcall 1
%push kcall
%undef %$ift
defiftoken %$ift, %1  ; True on NASM < 2.08.
%ifdef %$ift
%ifid %1
%defstr %$s %1
%xdefine __KCALL2__ kcall __imp__ %+ %1, %$s
%elifstr %1
deftok_compat %$n, __imp__, %1
%xdefine __KCALL2__ kcall %$n, %1
%else
%error 'Argument of kcall must be string or identifier.'
%define __KCALL2__ call dword [0]
%endif  ; %ifid/%elifstr %1
%else
%error 'Argument of kcall must be a single token.'
%define __KCALL2__ call dword [0]
%endif  ; %iftoken %1
%pop
__KCALL2__
%endmacro
%else
; The most common <60 KERNEL32.DLL function calls, including those used by
; OpenWatcom V2 with a program containing malloc, printf and strcmp.
%define __str__CloseHandle 'CloseHandle'
%define __str__CreateDirectoryA 'CreateDirectoryA'
%define __str__CreateDirectoryW 'CreateDirectoryW'
%define __str__CreateEventA 'CreateEventA'
%define __str__CreateFileA 'CreateFileA'
%define __str__DeleteFileA 'DeleteFileA'
%define __str__ExitProcess 'ExitProcess'
%define __str__FlushFileBuffers 'FlushFileBuffers'
%define __str__GetACP 'GetACP'
%define __str__GetCPInfo 'GetCPInfo'
%define __str__GetCommandLineA 'GetCommandLineA'
%define __str__GetCommandLineW 'GetCommandLineW'
%define __str__GetConsoleMode 'GetConsoleMode'
%define __str__GetCurrentProcessId 'GetCurrentProcessId'
%define __str__GetCurrentThreadId 'GetCurrentThreadId'
%define __str__GetEnvironmentStrings 'GetEnvironmentStrings'
%define __str__GetEnvironmentStringsA 'GetEnvironmentStringsA'
%define __str__GetEnvironmentStringsW 'GetEnvironmentStringsW'
%define __str__GetEnvironmentVariableA 'GetEnvironmentVariableA'
%define __str__GetEnvironmentVariableW 'GetEnvironmentVariableW'  ; Not implemented in WDOSX.
%define __str__GetFileType 'GetFileType'
%define __str__GetLastError 'GetLastError'
%define __str__GetLocalTime 'GetLocalTime'
%define __str__GetModuleFileNameA 'GetModuleFileNameA'
%define __str__GetModuleFileNameW 'GetModuleFileNameW'
%define __str__GetModuleHandleA 'GetModuleHandleA'
%define __str__GetOEMCP 'GetOEMCP'
%define __str__GetProcAddress 'GetProcAddress'
%define __str__GetProcessHeap 'GetProcessHeap'
%define __str__GetStdHandle 'GetStdHandle'
%define __str__GetTimeZoneInformation 'GetTimeZoneInformation'
%define __str__GetVersion 'GetVersion'
%define __str__HeapAlloc 'HeapAlloc'
%define __str__LoadLibraryA 'LoadLibraryA'
%define __str__LoadLibraryExA 'LoadLibraryExA'
%define __str__MoveFileA 'MoveFileA'
%define __str__MoveFileExA 'MoveFileExA'  ; Not implemented in WDOSX.
%define __str__MultiByteToWideChar 'MultiByteToWideChar'
%define __str__ReadConsoleInputA 'ReadConsoleInputA'
%define __str__ReadFile 'ReadFile'
%define __str__RemoveDirectoryA 'RemoveDirectoryA'
%define __str__RemoveDirectoryW 'RemoveDirectoryW'
%define __str__SetConsoleCtrlHandler 'SetConsoleCtrlHandler'
%define __str__SetConsoleMode 'SetConsoleMode'
%define __str__SetCurrentDirectoryA 'SetCurrentDirectoryA'
%define __str__SetCurrentDirectoryW 'SetCurrentDirectoryW'
%define __str__SetEnvironmentVariableA 'SetEnvironmentVariableA'
%define __str__SetFilePointer 'SetFilePointer'
%define __str__SetStdHandle 'SetStdHandle'
%define __str__SetUnhandledExceptionFilter 'SetUnhandledExceptionFilter'
%define __str__UnhandledExceptionFilter 'UnhandledExceptionFilter'
%define __str__VirtualAlloc 'VirtualAlloc'
%define __str__VirtualFree 'VirtualFree'
%define __str__VirtualQuery 'VirtualQuery'
%define __str__WideCharToMultiByte 'WideCharToMultiByte'
%define __str__WriteConsoleA 'WriteConsoleA'
%define __str__WriteFile 'WriteFile'

; Other KERNEL32.DLL functions implemented by WDOSX:
;
; AreFileApisANSI Borland32 CompareFileTime CompareStringA CompareStringW
; CopyFileA CreateDirectoryW CreateFileW CreateProcessA DebugBreak
; DeleteCriticalSection DeleteFileA DeleteFileW DosDateTimeToFileTime
; DuplicateHandle EnterCriticalSection EnumCalendarInfoA FileTimeToDosDateTime
; FileTimeToLocalFileTime FileTimeToSystemTime FindClose FindFirstFileA
; FindNextFileA FindResourceA FormatMessageA FreeEnvironmentStringsA
; FreeEnvironmentStringsW FreeLibrary FreeResource GetConsoleCP
; GetConsoleOutputCP GetCurrentDirectoryA GetCurrentProcess
; GetCurrentProcessId GetCurrentThread GetCurrentTime GetDateFormatA
; GetDiskFreeSpaceA GetDriveTypeA GetExitCodeProcess GetFileAttributesA
; GetFileAttributesW GetFileInformationByHandle GetFileSize GetFileTime
; GetFullPathNameA GetLocaleInfoA GetLogicalDriveStringsA GetLogicalDrives
; GetPrivateProfileStringA GetShortPathNameA GetStartupInfoA
; GetStringTypeA GetStringTypeW GetSystemDefaultLCID GetSystemDefaultLangID
; GetSystemInfo GetSystemTime GetSystemTimeAsFileTime GetTempFileNameA
; GetThreadLocale GetTickCount GetUserDefaultLCID GetVersionExA GetVersionExW
; GetVolumeInformationA GlobalAlloc GlobalFlags GlobalFree GlobalHandle
; GlobalLock GlobalMemoryStatus GlobalReAlloc GlobalSize GlobalUnlock
; HeapCreate HeapDestroy HeapFree HeapReAlloc HeapSize
; InitializeCriticalSection InterlockedDecrement InterlockedExchange
; InterlockedIncrement IsBadCodePtr IsBadHugeReadPtr IsBadHugeWritePtr
; IsBadReadPtr IsBadWritePtr IsDBCSLeadByteEx LCMapStringA LCMapStringW
; LeaveCriticalSection LoadResource LocalAlloc LocalFileTimeToFileTime
; LocalFree LocalReAlloc LockFile LockResource OutputDebugString
; QueryPerformanceCounter QueryPerformanceFrequency RaiseException
; ReadProcessMemory RtlFillMemory RtlMoveMemory RtlUnwind RtlZeroMemory
; SetEndOfFile SetEnvironmentVariableW SetFileApisToOEM SetFileAttributesA
; SetFileAttributesW SetFileTime SetHandleCount SetLastError SizeofResource
; SystemTimeToFileTime TerminateProcess TlsAlloc TlsFree TlsGetValue
; TlsSetValue UnlockFile VirtualProtect WritePrivateProfileStringA
; WriteProcessMemory

%macro kcall 1
%push kcall
%undef __KCALL2__
%ifid %1
%ifdef __str__%1
%define __KCALL2__ kcall __imp__%1, __str__%1
%else
%error 'In NASM <2.03, add quotes around argument of kcall.'
%define __KCALL2__ call dword [0]
%endif
%elifstr %1
deftok_compat %$n, __imp__, %1
%xdefine __KCALL__ kcall %$n,
%else
%error 'Argument of kcall must be string or identifier.'
%define __KCALL2__ call dword [0]
%endif
%pop
%ifdef __KCALL2__
__KCALL2__
%else
__KCALL__ %1
%endif
%endmacro
%endif  ; NASM version check for kcall/1.

; Usage: exit  ; Default exit code is 0.
; Usage: exit EXITCODE
%macro exit 0
exit 0
%endmacro
%macro exit 1
%ifnum %1
%if (%1)&~0x7f
push strict dword %1
%else
push strict byte %1
%endif
%else
push %1
%endif
kcall ExitProcess
%endmacro

; Helper macro (to be used in endpe/1).
%macro __AFTER_ENDPE__ 0+
  %error 'Please move all code and data above endpe.'
%endmacro

; You must call this at the end of your .nasm source file.
;
; Usage: endpe  ; Default entry point is at label _start.
; Usage: endpe _mystart  ; Entry point label.
;
; If you forget to call it at the end, NASM will report this error:
;    error: symbol `__PLEASE_CALL_endpe__' undefined
;    error: symbol `__PLEASE_CALL_endpe__' not defined before use
%macro endpe 0
  %ifdef __ENTRY_POINT__
  endpe __ENTRY_POINT__
  %else
  endpe _start
  %endif
%endmacro
%macro endpe 1  ; Argument: _start address.
  %ifdef __PLEASE_CALL_endpe__
  %error 'endpe called twice'
  %else
  %define __PLEASE_CALL_endpe__ __PLEASE_CALL_endpe__
  %endif
  __ENTRY_POINT__ equ (%1)
  section text
  %ifndef __imp__ExitProcess
  exit
  %endif
  section stub
  %if $-$$==0
    ; 0x40-byte PE DOS stub, based on:
    ; https://github.com/pts/pts-nasm-fullprog/blob/master/pe_stub1.nasm
    IMAGE_DOS_HEADER:
    .mz_signature: dw 'MZ'
    .image_size_lo: dw IMAGE_DOS_HEADER_end-IMAGE_DOS_HEADER
    .image_size_hi: dw 1
    dw 0, 1, 0x0fff, -1, 1, -1, 0, 8, 0
    ;aa $$+24
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
    dd _PEHEADER-__IMAGE_BASE__
    IMAGE_DOS_HEADER_end:
    %if IMAGE_DOS_HEADER_end-IMAGE_DOS_HEADER>0x200
      %error 'Default IMAGE_DOS_HEADER too long.'
    %endif
  %endif
  _STUB_end:
  section stubx
  times -((_STUB_end-_STUB)+($-_STUBX))&3 db 0
  ; Make peheader start at an offset divisble by 4.
  _STUBX_end:
  section peheader
  dd 0  ; !!! Why is this needed? Why can't it be omitted? A dw is not enough.
  _PEHEADER_end:
  section rodata
  _RODATA_before_padding:
  __IMAGE_SIZE_UPTO_TEXT_UNPADDED__ equ (_STUB_end-_STUB)+(_STUBX_end-_STUBX)+(_PEHEADER_end-_PEHEADER)+($-_RODATA)
  %if __IMAGE_SIZE_UPTO_TEXT_UNPADDED__<0x200
  times 0x200-__IMAGE_SIZE_UPTO_TEXT_UNPADDED__ db 'H'
  %endif
  _RODATA_end:
  section text
  _TEXT_end:
  section iat
  dd 0  ; Marks end-of-list.
  IMPORT_ADDRESS_TABLE_end:
  _IAT_end:
  section import
  %if $-_IMPORT_end!=0
  %error 'Please do not add anything to section import.'  ; IMAGE_IMPORT_DESCRIPTORS_end has to precede section bss.
  %endif
  section bss
  _BSS_end:
  __RVA_TEXT__ equ 0x1000
  ;__RVA_TEXT__ equ ((__IMAGE_SIZE_UPTO_TEXT__&~0x1ff)+0xfff)&~0xfff
  %if (_STUB_end-_STUB)+(_STUBX_end-_STUBX)+(_PEHEADER_end-_PEHEADER)+(_RODATA_end-_RODATA)<0x1000
  __IMAGE_SIZE_UPTO_TEXT__ equ (_STUB_end-_STUB)+(_STUBX_end-_STUBX)+(_PEHEADER_end-_PEHEADER)+(_RODATA_end-_RODATA)
  __VSTART_TEXT__ equ __IMAGE_BASE__+0x1000+(__IMAGE_SIZE_UPTO_TEXT__&0x1ff)
  %else
  ; TODO(pts): Make the header larger (and thus keep more of `section rodata' read-only).
  __IMAGE_SIZE_UPTO_TEXT__ equ 0x1000
  __VSTART_TEXT__ equ __IMAGE_BASE__+(_STUB_end-_STUB)+(_STUBX_end-_STUBX)+(_PEHEADER_end-_PEHEADER)+(_RODATA_end-_RODATA)
  %endif
  __PLEASE_CALL_endpe__ equ __VSTART_TEXT__
  %if __RVA_TEXT__<__IMAGE_SIZE_UPTO_TEXT__  ; Assert, shouldn't happen.
  ; Wine 5.0 doesn't care, but Windows NT 3.1, Windows 95 and Windows XP do.
  %error 'VirtualAddress of section text must be smaller than SizeOfHeader.'
  %endif
  __IMAGE_SIZE_UPTO_BSS__ equ __VSTART_TEXT__-__IMAGE_BASE__+(_TEXT_end-_TEXT)+(_IAT_end-_IAT)+(_IMPORT_end-_IMPORT)
  __IMAGE_SIZE__ equ __IMAGE_SIZE_UPTO_BSS__+(_BSS_end-_BSS)
  section endpe  ; Keep it going, catch accidental assembly instructions after endpe.
  ; Will cause: warning: attempt to initialize memory in a nobits section: ignored [-w+other]
  %if $-$$!=0
    __AFTER_ENDPE__
  %endif
  %idefine resb __AFTER_ENDPE__
  %idefine resw __AFTER_ENDPE__
  %idefine resd __AFTER_ENDPE__
  %idefine resq __AFTER_ENDPE__
  %idefine rest __AFTER_ENDPE__
  %idefine reso __AFTER_ENDPE__
  %idefine resy __AFTER_ENDPE__
  %idefine istruc __AFTER_ENDPE__
  %idefine section __AFTER_ENDPE__
  %idefine segment __AFTER_ENDPE__
  %idefine db __AFTER_ENDPE__
  %idefine dw __AFTER_ENDPE__
  %idefine dd __AFTER_ENDPE__
  %idefine dq __AFTER_ENDPE__
  %idefine dt __AFTER_ENDPE__
  %idefine do __AFTER_ENDPE__
  %idefine dy __AFTER_ENDPE__
  %idefine nop __AFTER_ENDPE__
%endmacro

section text

; __END__
