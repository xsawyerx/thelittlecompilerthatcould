#!/usr/bin/env perl
use strict;
use warnings;
use autodie;

my $asm = do { local $/ = <STDIN> };

open my $outfh, '>', 'output.asm';
print $outfh <<"EOF";
bits 32
extern _printf
global _main

	section .data
message db "eax = %d", 10, 0

	section .text
_main:
	$asm

	sub esp, 12
	mov dword[esp], message
	mov dword[esp+4], eax
	call _printf
	add esp, 12
	mov eax, 0
	ret
EOF
close $outfh;

system 'nasm -f macho -o output.o output.asm';
system 'ld -no_pie -o output -arch i386 output.o -macosx_version_min 10.7 -lc /usr/lib/crt1.o';
system './output';
system 'rm -f output output.o output.asm';

