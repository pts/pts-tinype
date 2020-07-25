pts-tinype: tiny hello-world Win32 PE .exe
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
pts-tinype is a set of tiny hello-world Win32 PE .exe executables for the
console (Command Prompt), with assembly source code. The smallest one,
hh2.golden.exe is just 402 bytes large, and it runs on Windows XP ...
Windows 10. The smallest one which runs on all Win32 systems (Windows NT 3.1
to Windows 10), hh5.golden.exe, is 1536 bytes.

How to run:

* Download and run hh2.golden.exe in the Command Prompt of any 32-bit (i386)
  or 64-bit (amd64, x86_64) Windows system or Wine. (It has been tested and
  it works on Windows XP, Windows 10 and Wine 1.6.2.)
* Alternatively, download and run hh5.golden.exe on Windows NT 3.1, Windows
  95, ..., Windows XP, ..., Windows 10 and Wine. It should work everywhere.
* Alternatively, if you don't have a Windows system to try it on, run it
  with Wine.
* Alternatively, if you don't have a Windows system to try it on, run it on
  a virtual machine running Windows. Example Windows XP virtual machine with
  QEMU:
  http://ptspts.blogspot.com/2017/09/how-to-run-windows-xp-on-linux-using-qemu-and-kvm.html

Size and compatibility matrix:

                     hh1   hh2   hh3gf hh3tf hh3wf hh4   hh5   hh6   hh6b
-------------------------------------------------------------------------
size (bytes)         633   402   2048  1536  3072  268   1024  688   604
Windows NT 3.1       --    --    yes   yes   yes   --    yes   yes   yes
Windows 95           --    --    yes   yes   yes   --    yes   yes   yes
Windows XP           yes   yes   yes   yes   yes   --    yes   yes   yes
Windows 7            yes   yes   yes   yes   yes   yes   yes   yes   yes
Windows 10 2020-07   yes   yes   yes   yes   yes   --    yes   yes   yes

Variants:

* hh1.golden.exe (663 bytes): Should work on Windows XP ... Windows 10.
* hh2.golden.exe (402 bytes): Should work on Windows XP ... Windows 10,
  contains some string constants overlapping header fields.
  It doesn't work on Windows NT 3.51 (not even after changing the
  SubsystemVersion to 3.10), and it doesn't work on Windows 95 either.
* hh3gf.golden.exe (2048 bytes): Works on Windows NT 3.1 ... Windows 10.
  Built with MinGW GCC from a .c source, and the SubsystemVersion field in
  the PE header was changed from 4.0 to 3.10 for Windows NT 3.1
  compatibility,
* hh3tf.golden.exe (2048 bytes): Works on Windows NT 3.1 ... Windows 10.
  Built with TCC 0.9.26 from a .c source, and the SubsystemVersion field in
  the PE header was changed from 4.0 to 3.10 for Windows NT 3.1
  compatibility,
* hh3wf.golden.exe (2048 bytes): Works on Windows NT 3.1 ... Windows 10.
  Built with OpenWatcom V2 owcc from a .c source, and the SubsystemVersion
  field in the PE header was changed from 4.0 to 3.10 for Windows NT 3.1
  compatibility,
* hh4.golden.exe (268 bytes): Doesn't work on Windows NT 3.1, Windows 95,
  Windows XP, works on Windows 7, doesn't work on Windows 10,
  should work on Windows Vista ... Windows 7,
  contains some string constants overlapping header fields. On 32-bit
  Windows 7 the first 256 bytes would have been enough.
* hh5.golden.exe (1024 bytes): Like hh3tf.exe, but smaller, because the
  .data section was merged to the .text section. It works on
  Windows NT 3.1--Windows 10, tested on Windows NT 3.1, Windows
  95, Windows XP and Wine 5.0.
* hh6.golden.exe (688 bytes): Like hh5.golden.exe, but contains optimized
  code for the hello-world, and the trailing 0 bytes are stripped.
  .data section was merged to the .text section. It works on
  Windows NT 3.1--Windows 10, tested on Windows NT 3.1, Windows
  95, Windows XP and Wine 5.0.
* hh6b.golden.exe (604 bytes): Like hh6.golden.exe, but some padding bytes
  and some image data directory entried were removed, and some read-only data
  has been moved from the .text section to the header. It works on
  Windows NT 3.1--Windows 10, tested on Windows NT 3.1, Windows
  95, Windows XP and Wine 5.0. It's not possible to go below 512 bytes,
  because Windows NT 3.1 and Windows 95 don't support section
  alignment lower than 512 or section starting at file offset 0. See
  hh2.golden.exe for the `-2' hack to make it work on Windows XP and Wine.
* hh7.golden.exe (677 bytes): Like hh6.golden.exe, but a few more padding
  bytes were removed. It still works on Windows NT 3.1--Windows 10.
  It uses NASM library smallpe.inc.nasm, for convenient creation of
  samll Win32 PE .exe executables using KERNEL32.DLL only.
* box1.golden.exe (268 bytes): Doesn't work on Windows XP, works on Windows
  7, should work on Windows Vista ... Windows 10,
  contains some string constants overlapping header fields. On 32-bit
  Windows 7 the first 261 bytes would have been enough.

How to compile:

* On a Unix system (e.g. Linux) with the `nasm' and `make' tools installed,
  just run `make' (without the quotes) in the directory containing hh2.nasm.
* Alternatively, on other systems, look at the beginning of the hh2.nasm and
  hh1.nasm source files for compilation instructions. On Windows, you may
  have to run `nasmw' instead of `nasm'.

Related projects and docs:

* https://www.codejuggle.dj/creating-the-smallest-possible-windows-executable-using-assembly-language/
  is a related project from 2015, and its tiny .exe is even smaller: 268
  bytes. Unfortunately it doesn't run on Windows XP (``The application
  failed to initialize properly (0xc0000007b). Click on OK to terminate the
  application.''. It works on Wine 1.6.2, Windows 7 32-bit,
  and its author claims that it runs on Windows 7 64-bit. See
  box1.nasm and box1.golden.exe for a copy of the code.
* The 268-byte PE .exe header pattern:
  http://pferrie.host22.com/misc/tiny/pehdr.htm
* 268-byte amd64 tiny PE .exe where every byte is executed:
  https://drakopensulo.wordpress.com/2017/08/06/smallest-pe-executable-x64-with-every-byte-executed/
* A longer, useful writeup on tiny PE .exe:
  http://www.phreedom.org/research/tinype/tiny.import.209/tiny.asm
  The subpage
  http://www.phreedom.org/research/tinype/tiny.import.209/tiny.asm
  contains 209-byte tiny.exe with an import. Windows XP SP3 says:
  ``Program too big to fit in memory''.
* Crinkler-related discussion of tiny PE .exe and the 268-byte minimum:
  http://www.pouet.net/topic.php?which=9565
* Crinkler (http://www.crinkler.net/), a combined linker and compressor to
  generate tiny Win32 PE .exe files. An .exe files generated by Crinkler 2.0
  (aw50cm8_by_knl__ishy.exe)
  didn't work for the author of hh2.nasm on Windows XP SP3 (even though
  the documentation of Crinkler explicitly says that Windows XP is
  supported). Crinkler 2.0 itself didn't work for the author of hh2.nasm on
  Windows XP SP3 (``The application failed to initialize properly
  (0xc0000022). Click OK to terminate the application.''.) Crinkler 2.0
  started up on Wine 1.6.2, but it failed to create an .exe file
  (``Oops! Crinkler has crashed.'', probably because the dbghelp.dll in Wine
  doesn't work.)
* https://code.google.com/archive/p/corkami/wikis/PE.wiki
  contains older documentation about PE.
* https://stackoverflow.com/questions/33247785/compile-windows-executables-with-nasm
  asks how to create Win32 PE .exe files with nasm.
* https://stackoverflow.com/questions/42022132/how-to-create-tiny-pe-win32-executables-using-mingw
  contains a C hello-world Win32 PE .exe, 2048 bytes.

Windows NT 3.1 .exe loader limitations:

* SectionAlignment must be 0x1000.
* FileAlignment must be >= 0x200.
* File size must be divisible by 0x200 (512).
* SubsystemVersion must be 3.10.
* hh3tf.golden.exe, 0x300 bytes, with 2 sections does work.
* Is there a solution with 1 section only (.text and .data combined), or
  maybe 2 sections (.data overlapping the first 0x200 byes and unused, and
  .text containing everything)? If it works, then 0x400 (1024) bytes would be
  the size of the smallest ultraportable (Windows NT 3.1--Windows 10) Win32
  PE .exe.

Windows XP .exe loader limitations:

* SizeOfOptionalHeader must be >= 0x78.
* NumberOfSections must be >= 3. (This isn't always the case, hh3tf.exe with
  only 2 sections does work.)
  2 or 1 don't work, 4 works.
* SectionAlignment must be 0x1000.
  Even 0x2000 doesn't work.
* FileAlignment must be >= 0x200.
  0x400 also works.
* A section cannot be loaded to ImageBase, minimum is ImageBase + 0x1000.
* SizeOfHeaders must be > 0.
* PointerToRawData is 0, then Windows XP doesn't load the section.
* Maybe the limitations above don't apply if we don't need any external
  libraries (not even kernel32.dll). This needs further investigation.

How was hh2.nasm created?

* The .nasm source in
  https://www.codejuggle.dj/creating-the-smallest-possible-windows-executable-using-assembly-language/
  was studied.
* The .exe created from the hello-world .c program in
  https://stackoverflow.com/questions/42022132/how-to-create-tiny-pe-win32-executables-using-mingw
  was manually converted back to .nasm, pointers changed to symbols and
  address computations added one-by-one.
* The 2nd .nasm file was gradually changed to resemble the 1st .nasm file,
  while making sure that the generated .exe still works on Windows XP.

__END__
