#! /usr/bin/python
# by pts@fazekas.hu at Sat Jan 13 17:30:18 CET 2018

text_bytes = 0x24
imported_names = ('ExitProcess', 'GetStdHandle', 'WriteFile')
library_names = ('kernel32')

if 'hh2.asm':
  total = 419
  overhead = (324
      + sum(len(name) for name in imported_names) + 2 * len(imported_names) - 1
      + 8 * len(imported_names) + 6
      + sum(len(name) for name in library_names) + len(library_names) - (len('kernel32') + 1) - (len('GetStdHandle') + 3))

print (total - overhead - text_bytes)
