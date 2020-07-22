;
; hh7.nasm: small (677 bytes), flexible and ultraportable Win32 PE .exe
; Compile: nasm -O0 -f bin -o hh7.exe hh7.nasm
;
; It works on Windows NT 3.1--Windows 10, tested on Windows NT 3.1, Windows
; 95, Windows XP, Windows 10 and Wine 5.0.
;
; This file is based on hh3tf.nasm, and .data section was merged to the
; .text section (-512 bytes), and the trailing 0 bytes have been removed.
;

%include "smallpe.inc.nasm"

_start:
push strict byte -11  ; STD_OUTPUT_HANDLE.
; For NASM >= 2.03, you can just use: kcall GetStdHandle
kcall GetStdHandle, 'GetStdHandle'
;push eax  ; Save stdout handle.
push eax  ; Value is arbitrary, we allocate an output variable on the stack.
mov ebx, esp
push strict byte 0  ; Argument 5: lpOverlapped = 0.
push ebx  ; Argument 4: Address of the output variable.
push strict byte message_end-message  ; Argument 3: message size.
push strict dword message  ; Argument 2: message.
push eax  ; if it was saved, strict dword [esp+20]  ; Argument 1: Stdout handle.
kcall WriteFile, 'WriteFile'
push strict byte 0  ; EXIT_SUCCESS == 0.
kcall ExitProcess, 'ExitProcess'
;add esp, 8  ; Too late, we've already exited.
;ret  ; Too late, we've already exited.

message:
db 'Hello, World!', 13, 10
message_end:

endpe
