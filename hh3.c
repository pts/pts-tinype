/* Based on https://stackoverflow.com/questions/42022132/how-to-create-tiny-pe-win32-executables-using-mingw */

#include <windows.h>

/* _start() works with MinGW and TCC (#ifdef __TINYC__), and it also works with
 * OpenWatcom V2 if startw.o is also linked.
 * mainCRTStartup() works for MinGW, but not TCC or OpenWatcom V2.
 */
void __cdecl _start(void) {
  DWORD bw;
  HANDLE hfile = GetStdHandle(STD_OUTPUT_HANDLE);
  WriteFile(hfile, "Hello, World!\r\n", 15, &bw, 0);
  ExitProcess(0);  /* Needed for successful (0) exit. */
}
