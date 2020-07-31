/* hh3t.c: non-console Win32 PE .exe (with relocations if compiled with owcc) */

#include <windows.h>

/* _start() works with MinGW and TCC (#ifdef __TINYC__), and it also works with
 * OpenWatcom V2 if startw.o is also linked.
 * mainCRTStartup() works for MinGW, but not TCC or OpenWatcom V2.
 */
void __cdecl _start(void) {
  const HANDLE user32 = LoadLibraryA("user32.dll");
  int (__stdcall * const MessageBoxA)(HWND hWnd, LPCSTR lpText, LPCSTR lpCaption, UINT uType) = user32 ? (void*)GetProcAddress(user32, "MessageBoxA") : NULL;
  const int status = MessageBoxA ? MessageBoxA(0, "Hello,\nWorld!", "World!", 0) : 99;
  ExitProcess(!status);  /* Needed for successful (0) exit. */
}
