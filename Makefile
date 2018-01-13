.PHONY: all clean

# hh3.exe is not here.
all: hh1.exe hh2.exe

hh1.exe: hh1.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
hh2.exe: hh2.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
hh3.exe: hh3.c
	i686-w64-mingw32-gcc -m32 -mconsole -s -Os -fno-ident -fno-stack-protector -fomit-frame-pointer -fno-unwind-tables -fno-asynchronous-unwind-tables -falign-functions=1  -mpreferred-stack-boundary=2 -falign-jumps=1 -falign-loops=1 -nostdlib -nodefaultlibs -nostartfiles -o $@ $< -lkernel32
	-chmod 755 $@
box1.exe: box1.nasm
	nasm -Ox -f bin -o $@ $<
	-chmod 755 $@

clean:
	rm -f hh1.exe hh2.exe hh3.exe box1.exe
