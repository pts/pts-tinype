#! /bin/sh --
# Usage: bin2nasm.sh input.bin >output.nasm
exec perl -0777 -ne '
  BEGIN { $^W = 1 } use integer; use strict;
  print "; Compile: nasm -O0 -f bin -o t.bin t.nasm\n\n; Asserts that we are at offset %1 from the beginning of the input file\n%macro aa 1\ntimes \$-(%1) times 0 nop\ntimes (%1)-\$ times 0 nop\n%endmacro\n\n";
  for (my $i = 0; $i <= length($_); $i += 16) {
    printf "aa \$\$+0x%04x\n", $i;
    last if $i >= length($_);
    printf "dd 0x%08x, 0x%08x, 0x%08x, 0x%08x\n", unpack("VVVV", substr($_, $i, 16));
  }' -- "$@"
