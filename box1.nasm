; Downloaded from https://www.codejuggle.dj/creating-the-smallest-possible-windows-executable-using-assembly-language/
; on 2018-01-13, original post on 2015-05-04.
;
; box1.exe works on Wine 1.6.2, but it doesn't work on Windows XP SP3 for
; the author of hh2.nasm. According to the author of box1.nasm, box1.exe
; works on Windows 7 64-bit. The author of hh2.nasm has checked that
; box1.exe works on Windows 7 32-bit.
;
IMAGEBASE equ 400000h

BITS 32
ORG IMAGEBASE
; IMAGE_DOS_HEADER
  dw "MZ"                       ; e_magic
  dw 0                          ; e_cblp

; IMAGE_NT_HEADERS - lowest possible start is at 0x4
Signature:
  dw 'PE',0                     ; Signature

; IMAGE_FILE_HEADER
  dw 0x14c                      ; Machine = IMAGE_FILE_MACHINE_I386
  dw 0                          ; NumberOfSections
user32.dll:
  dd 'user'                     ; TimeDateStamp
  db '32',0,0                   ; PointerToSymbolTable
  dd 0                          ; NumberOfSymbols
  dw 0                          ; SizeOfOptionalHeader
  dw 2                          ; Characteristics = IMAGE_FILE_EXECUTABLE_IMAGE

; IMAGE_OPTIONAL_HEADER32
  dw 0x10B                      ; Magic = IMAGE_NT_OPTIONAL_HDR32_MAGIC
kernel32.dll:
  db 'k'                        ; MajorLinkerVersion
  db 'e'                        ; MinorLinkerVersion
  dd 'rnel'                     ; SizeOfCode
  db '32',0,0                   ; SizeOfInitializedData
  dd 0                          ; SizeOfUninitializedData
  dd Start - IMAGEBASE          ; AddressOfEntryPoint
  dd 0                          ; BaseOfCode
  dd 0                          ; BaseOfData
  dd IMAGEBASE                  ; ImageBase
  dd 4                          ; SectionAlignment - overlapping address with IMAGE_DOS_HEADER.e_lfanew
  dd 4                          ; FileAlignment
  dw 0                          ; MajorOperatingSystemVersion
  dw 0                          ; MinorOperatingSystemVersion
  dw 0                          ; MajorImageVersion
  dw 0                          ; MinorImageVersion
  dw 4                          ; MajorSubsystemVersion
  dw 0                          ; MinorSubsystemVersion
  dd 0                          ; Win32VersionValue
  dd 0x40                       ; SizeOfImage
  dd 0                          ; SizeOfHeaders
  dd 0                          ; CheckSum
  dw 2                          ; Subsystem = IMAGE_SUBSYSTEM_WINDOWS_CUI
  dw 0                          ; DllCharacteristics
  dd 0                          ; SizeOfStackReserve
  dd 0                          ; SizeOfStackCommit
  dd 0                          ; SizeOfHeapReserve
  dd 0                          ; SizeOfHeapCommit
  dd 0                          ; LoaderFlags
  dd 2                          ; NumberOfRvaAndSizes

; IMAGE_DIRECTORY_ENTRY_EXPORT
  dd 0                          ; VirtualAddress
  dd 0                          ; Size

; IMAGE_DIRECTORY_ENTRY_IMPORT
  dd IMAGE_IMPORT_DESCRIPTOR - IMAGEBASE ; VirtualAddress

Start:
  push  0                       ; = MB_OK - overlapps with IMAGE_DIRECTORY_ENTRY_IMPORT.Size
  push  world
  push  hello
  push  0
  call  [MessageBoxA]
  push  0
  call  [ExitProcess]

kernel32.dll_iat:
ExitProcess:
  dd impnameExitProcess - IMAGEBASE
  dd 0
kernel32.dll_hintnames:
  dd impnameExitProcess - IMAGEBASE
  dw 0

impnameExitProcess:             ; IMAGE_IMPORT_BY_NAME
  dw 0                          ; Hint, terminate list before
  db 'ExitProcess'              ; Name
impnameMessageBoxA:             ; IMAGE_IMPORT_BY_NAME
  dw 0                          ; Hint, terminate string before
  db 'MessageBoxA', 0           ; Name

user32.dll_iat:
MessageBoxA:
  dd impnameMessageBoxA - IMAGEBASE
  dd 0
user32.dll_hintnames:
  dd impnameMessageBoxA - IMAGEBASE
  dd 0

IMAGE_IMPORT_DESCRIPTOR:
; IMAGE_IMPORT_DESCRIPTOR for kernel32.dll
  dd kernel32.dll_hintnames - IMAGEBASE ; OriginalFirstThunk / Characteristics
world:
  db 'worl'                     ; TimeDateStamp
  db 'd!',0,0                   ; ForwarderChain
  dd kernel32.dll - IMAGEBASE   ; Name
  dd kernel32.dll_iat - IMAGEBASE ; FirstThunk

; IMAGE_IMPORT_DESCRIPTOR for user32.dll
  dd user32.dll_hintnames - IMAGEBASE ; OriginalFirstThunk / Characteristics
hello:
  db 'Hell'                     ; TimeDateStamp
  db 'o',0,0,0                  ; ForwarderChain
  dd user32.dll - IMAGEBASE     ; Name
  dd user32.dll_iat - IMAGEBASE ; FirstThunk

; IMAGE_IMPORT_DESCRIPTOR empty one to terminate the list all bytes after the end will be zero in memory
times 7 db 0                    ; fill up exe to be 268 byte, smallest working exe for win7 64bit
