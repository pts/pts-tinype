.PHONY: all clean

# hh3.exe is not here, it needs a cross-compiler to build.
all: hh1.exe hh2.exe hh4.exe box1.exe

hh1.exe: hh1.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
hh2.exe: hh2.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
hh3.exe: hh3.c
	i686-w64-mingw32-gcc -m32 -mconsole -s -Os -fno-ident -fno-stack-protector -fomit-frame-pointer -fno-unwind-tables -fno-asynchronous-unwind-tables -falign-functions=1  -mpreferred-stack-boundary=2 -falign-jumps=1 -falign-loops=1 -nostdlib -nodefaultlibs -nostartfiles -o $@ $< -lkernel32
	-chmod 755 $@
hh3t.exe: hh3.c
	wine tcc -s -O2 -W -Wall -Wextra -nostdlib -o $@ $< -lkernel32
	-chmod 755 $@
hh3tf.exe: hh3tf.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
hh3w.exe: hh3.c startw.o
	owcc -I"$(WATCOM)"/h/nt -fno-stack-check -bwin32 -march=i386 -Wl,runtime -Wl,console=3.10 -W -Wall -Wextra -s -Os -fnostdlib -o $@ $< startw.o
	-chmod 755 $@
hh4.exe: hh4.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
hh5.exe: hh5.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
hh6.exe: hh6.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
box1.exe: box1.nasm
	nasm -Ox -f bin -o $@ $<
	-chmod 755 $@

clean:
	rm -f hh1.exe hh2.exe hh3.exe hh4.exe box1.exe
