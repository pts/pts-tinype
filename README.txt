pts-tinype: tiny hello-world Win32 PE .exe
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
pts-tinype is a set of tiny hello-world Win32 PE .exe executables for the
console (Command Prompt), with assembly source code. The smallest one,
hh2.golden.exe is just 404 bytes large, and it runs on Windows XP ...
Windows 10.

How to run:

* Download and run hh2.golden.exe in the Command Prompt of any 32-bit (i386)
  or 64-bit (amd64, x86_64) Windows system or Wine. (It has been tested and
  it works on Windows XP, Windows 10 and Wine 1.6.2.)
* Alternatively, if you don't have a Windows system to try it on, run it
  with Wine.
* Alternatively, if you don't have a Windows system to try it on, run it on
  a virtual machine running Windows. Example Windows XP virtual machine with
  QEMU:
  http://ptspts.blogspot.com/2017/09/how-to-run-windows-xp-on-linux-using-qemu-and-kvm.html

How compile:

* On a Unix system (e.g. Linux) with the `nasm' and `make' tools installed,
  just run `make' (without the quotes) in the directory containing hh2.nasm.
* Alternatively, on other systems, look at the beginning of the hh2.nasm and
  hh1.nasm source files for compilation instructions. On Windows, you may
  have to run `nasmw' instead of `nasm'.

https://www.codejuggle.dj/creating-the-smallest-possible-windows-executable-using-assembly-language/
is a related project from 2015, and its tiny .exe is even smaller: 268
bytes. Unfortunately it doesn't run on Windows XP. (It runs on Wine 1.6.2
though, and its author claims that it runs on Windows 7 64-bit.)

__END__
