#!/usr/bin/env perl
use strict;
use warnings;
use v5.14;
no warnings 'experimental';

# we're replacing Crenshaw's Error with carp(), and Abort with croak()
use Carp qw(carp croak);

my $Look; # lookahead character
my $Code; # entire program is slurped here
my $Current = 0;

# this assumes input is ascii
sub get_char {
    $Look = substr $Code, $Current++, 1;
}

sub expected {
    my ($s) = @_;
    croak "$s expected";
}

sub match {
    my ($x) = @_;

    $Look eq $x
        or expected "'$x'";

    get_char();
}

sub get_name {
    $Look =~ /[a-z]/i
        or expected 'Name';
    my $result = uc $Look;
    get_char();
    return $result;
}

sub get_number {
    $Look =~ /[0-9]/
        or expected 'Integer';
    my $result = $Look;
    get_char();
    return $result;
}

sub emit {
    my ($s) = @_;
    print "\t$s";
}

sub emitln {
    my ($s) = @_;
    print "\t$s\n";
}

sub term {
    factor();
    while ( $Look eq '*' or $Look eq '/' ) {
        emitln('push eax');
        given ($Look) {
            multiply() when '*';
            divide() when '/';
            default { expected 'Mulop' }
        }
    }
}

sub expression {
    term();
    while ( $Look eq '+' or $Look eq '-' ) {
        emitln('push eax');
        given ($Look) {
            add()      when '+';
            subtract() when '-';
            default { expected 'Addop' };
        }
    }
}

sub add {
    match '+';
    term();
    emitln('pop ebx');
    emitln('add eax,ebx');
}

sub subtract {
    match '-';
    term();
    emitln('pop ebx');
    emitln('sub eax,ebx');
    emitln('neg eax');
}

sub factor {
    emitln( 'mov eax, ' . get_number() );
}

sub multiply {
    match('*');
    factor();
    emitln('pop ebx');
    emitln('mul ebx');
}

sub divide {
    match('/');
    factor();
    emitln('mov ebx, eax');
    emitln('mov edx, 0');
    emitln('pop eax');
    emitln('div ebx');    # eax = ( eax + (edx<<32) ) / ebx
}

sub init {
    local $/;
    $Code = <STDIN>;
    get_char();
}

sub main {
    init();
    expression();
}

main();
