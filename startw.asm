; WASM (Watcom Assembler) source file for the Win32 entry point not using the
; OpenWatcom V2 C library. The function `void __cdecl _start(void) {' should
; be implemented in C.
;
; Compile option 1: owcc -bwin32 -c startw.asm
; Compile option 2: wasm startw.asm
;
.387
.386p
.model flat
		PUBLIC	_mainCRTStartup
		EXTRN	__start:BYTE
DGROUP		GROUP	CONST,CONST2,_DATA
_TEXT		SEGMENT	BYTE PUBLIC USE32 'CODE'
		ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP
_mainCRTStartup:
	jmp		near ptr FLAT:__start
_TEXT		ENDS
CONST		SEGMENT	DWORD PUBLIC USE32 'DATA'
CONST		ENDS
CONST2		SEGMENT	DWORD PUBLIC USE32 'DATA'
CONST2		ENDS
_DATA		SEGMENT	DWORD PUBLIC USE32 'DATA'
_DATA		ENDS
		END _mainCRTStartup
