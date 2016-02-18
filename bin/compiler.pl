#!/usr/bin/env perl
use strict;
use warnings;

# we're replacing Crenshaw's Error with carp(), and Abort with croak()
use Carp qw(carp croak);

my $Look; # lookahead character
my $Code; # entire program is slurped here
my $Current = 0;

sub get_char {
    substr $Code, $Current++, 1;
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

sub init {
    local $/;
    $Code = <STDIN>;
    get_char();
}

sub main {
    init();
}

main();
