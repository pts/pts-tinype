/* Based on https://stackoverflow.com/questions/42022132/how-to-create-tiny-pe-win32-executables-using-mingw */

#include <windows.h>

void __cdecl mainCRTStartup() {
  DWORD bw;
  HANDLE hfile = GetStdHandle(STD_OUTPUT_HANDLE);
  WriteFile(hfile, "Hello, World!\r\n", 15, &bw, 0);
  ExitProcess(0);  /* Needed for successful (0) exit. */
}
