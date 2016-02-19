package Cradle;
use strict;
use warnings;
use constant TAB => "\t";

my $look;

# Read New Character From Input Stream
sub GetChar {
    $look = getc();
}

# Report an Error
sub Error {
    my $error = shift;
    print "\nError: $error.\n";
}

# Report Error and Halt
sub Abort {
    my $string = shift;
    Error($string);
    exit;
}

# Report What Was Expected
sub Expected {
    my $string = shift;
    Abort("$string Expected");
}

sub Match {
    my $x = shift;
    if ( $look eq $x ) {
        GetChar();
    } else {
        Expected("'$x'");
    }
}

sub IsAlpha {
    my $c = shift;
    $c =~ /^[A-Z]$/i;
}

sub IsDigit {
    my $c = shift;
    $c =~ /^[0-9]$/;
}

sub GetName {
    if ( ! IsAlpha($look) ) {
        Expected('Name');
    }

    my $ret = $look;
    GetChar();
    return $ret;
}

sub GetNum {
    if ( ! IsDigit($look) ) {
        Expected('Integer');
    }

    my $ret = $look;
    GetChar();
    return $ret;
}

# Output a String with Tab
sub Emit {
    my $s = shift;
    print TAB, $s;
}

# Output a String with Tab and CRLF
sub EmitLn {
    my $s = shift;
    Emit("$s\n");
}

# Initialize
sub Init {
    GetChar();
}

# Main Program
Init();
