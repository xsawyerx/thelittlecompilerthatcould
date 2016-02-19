package Lib::Utils::CheckType;

use Exporter qw(import);

our @EXPORT_OK = qw(is_alpha is_digit);

sub is_alpha {
    my $char = shift;
    return $char =~  m/[A-Z]/;
}

sub is_digit {
    my $char = shift;
    return $char =~ m/[0-9]/;
}

1;
