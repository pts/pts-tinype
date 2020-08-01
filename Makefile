.PHONY: all clean

# hh3*.exe are not here, they need a cross-compiler to build.
all: hh1.exe hh2.exe hh2d.exe hh3tgn.exe hh4t.exe hh6a.exe hh6b.exe hh6c.exe hh6d.exe hh7.exe box1.exe

hh1.exe: hh1.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
hh2.exe: hh2.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
hh2d.exe: hh2d.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
hh3g.exe: hh3.c
	i686-w64-mingw32-gcc -m32 -Wl,--subsystem=windows:3.10 -Wl,--dynamicbase -s -Os -fno-ident -fno-stack-protector -fomit-frame-pointer -fno-unwind-tables -fno-asynchronous-unwind-tables -falign-functions=1  -mpreferred-stack-boundary=2 -falign-jumps=1 -falign-loops=1 -nostdlib -nodefaultlibs -nostartfiles -o $@ $< -lkernel32
	-chmod 755 $@
hh3t.exe: hh3.c
	wine tcc -m32 -s -O2 -W -Wall -Wextra -nostdlib -o $@ $< -lkernel32
	-chmod 755 $@
hh3w.exe: hh3.c startw.o
	owcc -I"$(WATCOM)"/h/nt -fno-stack-check -bwin32 -march=i386 -Wl,runtime -Wl,console=3.10 -W -Wall -Wextra -s -Os -fnostdlib -o $@ $< startw.o
	-chmod 755 $@
hh3tw.exe: hh3t.c startw.o
	owcc -I"$(WATCOM)"/h/nt -fno-stack-check -bwin32 -march=i386 -Wl,runtime -Wl,windows=3.10 -W -Wall -Wextra -s -Os -fnostdlib -o $@ $< startw.o
	-chmod 755 $@
hh3tg.exe: hh3t.c startw.o
	i686-w64-mingw32-gcc -m32 -Wl,--subsystem=windows:3.10 -Wl,--dynamicbase -s -Os -fno-ident -fno-stack-protector -fomit-frame-pointer -fno-unwind-tables -fno-asynchronous-unwind-tables -falign-functions=1  -mpreferred-stack-boundary=2 -falign-jumps=1 -falign-loops=1 -nostdlib -nodefaultlibs -nostartfiles -o $@ $< -lkernel32
	-chmod 755 $@
hh3tgn.exe: hh3tgn.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
hh4t.exe: hh4t.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
hh6a.exe: hh6a.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
hh6b.exe: hh6b.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
hh6c.exe: hh6c.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
hh6d.exe: hh6d.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
hh7.exe: hh7.nasm smallpe.inc.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
box1.exe: box1.nasm
	nasm -Ox -f bin -o $@ $<
	-chmod 755 $@

clean:
	rm -f hh1.exe hh2.exe hh2d.exe hh3g.exe hh3t.exe hh3w.exe hh6?.exe hh7.exe box1.exe
