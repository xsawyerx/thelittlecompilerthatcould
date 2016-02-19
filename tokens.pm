use v5.18;

use strict;
use warnings;

package IntToken;

sub new {
    my $class = shift;
    my %args  = @_;

    my $self = {
        value => $args{value}
    };

    return bless $self => $class;
}

sub lbp { '0' };

sub nud {
    my $self = shift;
    my ( $parser ) = @_;
    return $self->{value};
}

use overload
    '""' => \&stringify;

sub stringify {
    my ($self) = @_;
    return "l$self->{value}";
}

package AddToken;

sub new {
    my $class = shift;
    my %args  = @_;

    my $self = {
    };

    return bless $self => $class;
}

sub lbp { '10' }

sub led {
    my $self = shift;
    my ( $parser, $left ) = @_;

    my $right = $parser->expression($self->lbp);
    return $left + $right;
}

use overload
    '""' => \&stringify;

sub stringify {
    my ($self) = @_;
    return "+";
}

package SubtractToken;

sub new {
    my $class = shift;
    my %args  = @_;

    my $self = {
    };

    return bless $self => $class;
}

sub lbp { '10' }

sub led {
    my $self = shift;
    my ( $parser, $left ) = @_;

    my $right = $parser->expression($self->lbp);
    return $left - $right;
}

use overload
    '""' => \&stringify;

sub stringify {
    my ($self) = @_;
    return "-";
}

package MultiplyToken;

sub new {
    my $class = shift;
    my %args  = @_;

    my $self = {
    };

    return bless $self => $class;
}

sub lbp { '20' }

sub led {
    my $self = shift;
    my ( $parser, $left ) = @_;

    my $right = $parser->expression($self->lbp);
    return $left * $right;
}

use overload
    '""' => \&stringify;

sub stringify {
    my ($self) = @_;
    return "*";
}

package PowerToken;

sub new {
    my $class = shift;
    my %args  = @_;

    my $self = {
    };

    return bless $self => $class;
}

sub lbp { '30' }

sub led {
    my $self = shift;
    my ( $parser, $left ) = @_;

    my $right = $parser->expression($self->lbp-1);
    return $left ** $right;
}

use overload
    '""' => \&stringify;

sub stringify {
    my ($self) = @_;
    return "**";
}

package DivideToken;

sub new {
    my $class = shift;
    my %args  = @_;

    my $self = {
    };

    return bless $self => $class;
}

sub lbp { '20' }

sub led {
    my $self = shift;
    my ( $parser, $left ) = @_;

    my $right = $parser->expression($self->lbp);
    return $left / $right;
}

use overload
    '""' => \&stringify;

sub stringify {
    my ($self) = @_;
    return "/";
}

package IntDivideToken;

sub new {
    my $class = shift;
    my %args  = @_;

    my $self = {
    };

    return bless $self => $class;
}

sub lbp { '20' }

sub led {
    my $self = shift;
    my ( $parser, $left ) = @_;

    my $right = $parser->expression($self->lbp);
    return int($left / $right);
}

use overload
    '""' => \&stringify;

sub stringify {
    my ($self) = @_;
    return "//";
}

package EndToken;

sub new {
    my $class = shift;
    my %args  = @_;

    my $self = {
        value => $args{value}
    };

    return bless $self => $class;
}

sub lbp { '0' };

use overload
    '""' => \&stringify;

sub stringify {
    my ($self) = @_;
    return "endl";
}

1;