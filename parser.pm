package Parser;

use v5.18;

use strict;
use warnings;

use tokens;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Indent   = 1;
$Data::Dumper::Terse    = 1;

sub new {
    my $class = shift;
    my %args  = @_;

    my $self = {
        token_index   => 0,
        tokens        => $args{tokens} // [],
    };

    return bless $self => $class;
}

sub current {
    my $self = shift;
    $self->{current} //= $self->token_object(
        $self->{tokens}[$self->{token_index}]
    );
    return $self->{current};
}

sub next {
    my $self = shift;
    $self->{token_index}++;
    $self->{current} = $self->token_object(
        $self->{tokens}[$self->{token_index}]
    );
}

sub parse {
    my $self = shift;

    return $self->expression;
}

sub expression {
    my $self = shift;

    my ( $rbp ) = @_;
    $rbp      //= 0;

    my $t = $self->current;
    $self->next();
    my $left    = $t->nud($self);
    my $lbp     = $self->current->lbp($self);
    while( $rbp < $self->current->lbp($self) ) {
        $t = $self->current;
        $self->next();
        $left    = $t->led($self, $left);
        $lbp     = $self->current->lbp($self);
    }

    return $left;
}

sub token_object {
    my $self = shift;
    my ( $token ) = @_;

    my $classes = {
        INTEGER       => "IntToken",
        OP_ADD        => "AddToken",
        OP_SUBTRACT   => "SubtractToken",
        OP_MULTIPLY   => "MultiplyToken",
        OP_DIVIDE     => "DivideToken",
        OP_INT_DIVIDE => "IntDivideToken",
        OP_POWER      => "PowerToken",
        ENDL          => "EndToken",
    };
    my $class  = $classes->{$token->{type}};
    my $object = $class->new(value => $token->{value});

    return $object;
}

sub __TEST__ {
    my $parser = Parser->new(
        tokens => [
            { type => 'INT', value => 9 },
            { type => 'OP_ADD',         },
            { type => 'INT', value => 8 },
            { type => 'OP_SUBTRACT',  },
            { type => 'INT', value => 7 },
            { type => 'OP_MULTIPLY',  },
            { type => 'INT', value => 6 },
            { type => 'OP_INT_DIVIDE',  },
            { type => 'INT', value => 5 },
            { type => 'OP_MULTIPLY',  },
            { type => 'INT', value => 4 },
            { type => 'OP_POWER',  },
            { type => 'INT', value => 3 },
            { type => 'OP_POWER',  },
            { type => 'INT', value => 2 },
            { type => 'ENDL',           },
        ],
    );

    print $parser->parse;
}
1;
=pod

=head1 Expression parsing module

=cut