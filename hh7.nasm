;
; hh7.nasm: small (604 bytes), flexible and ultraportable Win32 PE .exe
; by pts@fazekas.hu on 2020-07-25
;
; Compile: nasm -O0 -f bin -o hh7.exe hh7.nasm
;
; It works on Windows NT 3.1--Windows 10, tested on Windows NT 3.1, Windows
; 95, Windows XP, Windows 7, Windows 10 and Wine 5.0.
;

%include "smallpe.inc.nasm"

_start:
push strict byte -11  ; STD_OUTPUT_HANDLE.
kcall GetStdHandle  ; Calls function in KERNEL32.DLL.
;push eax  ; Save stdout handle.
push eax  ; Value is arbitrary, we allocate an output variable on the stack.
mov ebx, esp
push strict byte 0  ; Argument 5: lpOverlapped = 0.
push ebx  ; Argument 4: Address of the output variable.
push strict byte message_end-message  ; Argument 3: message size.
push strict dword message  ; Argument 2: message.
push eax  ; if it was saved, strict dword [esp+20]  ; Argument 1: Stdout handle.
kcall WriteFile
;push strict byte 0  ; EXIT_SUCCESS == 0.
;kcall ExitProcess  ; Automatic.
;add esp, 8  ; Too late, we've already exited.
;ret  ; Too late, we've already exited.

section rodata  ; Optional, but makes the .exe output smaller.
message:
; To make the header span over 0x200 bytes:
;db 'Hello, World! MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM', 13, 10, 'MSG', 13, 10
db 'Hello, World!', 13, 10
message_end:

section stubx
;times 333333 db 'S'  ; Make the DOS stub larger.

endpe
