.PHONY: all clean

all: hh1.exe hh2.exe

hh1.exe: hh1.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@
hh2.exe: hh2.nasm
	nasm -O0 -f bin -o $@ $<
	-chmod 755 $@

clean:
	rm -f hh1.exe hh2.exe
