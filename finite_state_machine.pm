package FiniteStateMachine;
use v5.18;

use strict;
use warnings;

use Data::Dumper;
local $Data::Dumper::Sortkeys = 1;
local $Data::Dumper::Indent   = 0;
local $Data::Dumper::Terse    = 1;

sub new {
    my $class = shift;

    my %args = @_;

    my $self = {
        initial_state  => $args{initial_state} // 0,
        args           => $args{args} // {},
        current_state  => $args{initial_state},
        states         => { $args{initial_state} => 1 },
        metachars      => $class->default_metachar,
        transitions    => {},
        hooks          => {},
        error_callback => $args{error_callback},
    };

    $self = bless $self => $class;

    $self->add_transition_list( $args{transitions} );

    return $self;
}

sub default_metachar {
    my $class = shift;

    return {
        '\*' => [  # all ASCII chars ( + ext )
            map { chr($_) } 0 .. 255,
        ],
        '\d' => ['0'..'9'], # all digits
        '\D' => [ # all non digits
            (map { chr($_) } 0 .. (ord('0') - 1)),
            (map { chr($_) } ((ord('9') + 1) .. 255)),
        ],
        '\a' => [ # all alpha
            'a' .. 'z',
            'A' .. 'Z',
        ],
        '\A' => [ # all non alpha
            (map { chr($_) } 0 .. (ord('A') - 1)),
            (map { chr($_) } (ord('Z') + 1) .. (ord('a') - 1)),
            (map { chr($_) } (ord('z') + 1) .. 255),
        ],
        '\w' => [ # all word chars
            '0' .. '9',
            'a' .. 'z',
            'A' .. 'Z',
            '_',
        ],
        '\W' => [ # all non word chars
            (map { chr($_) } 0 .. (ord('0') - 1)),
            (map { chr($_) } (ord('9') + 1) .. (ord('A') - 1)),
            (map { chr($_) } (ord('Z') + 1) .. (ord('_') - 1)),
            (map { chr($_) } (ord('_') + 1) .. (ord('a') - 1)),
            (map { chr($_) } (ord('z') + 1) .. 255),
        ],
        '\n' => ["\n"],
        '\t' => ["\t"],
        '\r' => ["\r"],
        '\f' => ["\f"],
        '\s' => ["\n", "\t", "\r", "\f", ' '], # all whitespaces
        '\S' => [ # all non whitespaces
            (map { chr($_) } 0 .. (ord("\t") - 1)),
            (map { chr($_) } (ord("\n") + 1) .. (ord("\f") - 1)),
            (map { chr($_) } (ord("\r") + 1) .. (ord(' ') - 1)),
            (map { chr($_) } (ord(' ') + 1) .. 255),
        ],
    }
}

sub add_metachar {
    my $self = shift;
    my ( $metachar, $chars ) = @_;
    $self->{metachars}{$metachar} = $chars;
}

sub reset {
    my $self = shift;

    $self->{current_state} = $self->{initial_state};
}

sub add_transition_list {
    my $self = shift;
    my ($transitions) = @_;

    for my $transition ( @{ $transitions // [] } ) {
        $self->add_transition( @{$transition} );
    }
}

sub add_transition {
    my $self = shift;
    my ( $start_state, $symbols, $next_state, $action ) = @_;

    $self->{states}{$start_state} //= 1;
    $self->{states}{$next_state}  //= 1;

    # In order to symplify the input, we make it possible
    # to specify a list of symbols leading to the next state
    $symbols = [$symbols] unless ref $symbols;
    for my $symbol ( @{$symbols} ) {
        my $chars = $self->{metachars}{$symbol} // [$symbol];
        for my $char ( @{$chars} ){
            $self->{transitions}{$start_state}{$char} = $next_state;
            $self->add_hook($start_state, $char, $action);
        }
    }
}

sub add_hook {
    my $self = shift;
    my ( $start_state, $symbols, $action ) = @_;

    return unless defined $action;

    $symbols = [$symbols] unless ref $symbols eq 'ARRAY';

    for my $symbol (@{$symbols}){
        my $hooks_list = $self->{hooks}{$start_state}{$symbol} //= [];
        push $hooks_list, $action;
    }
}

sub get_hooks {
    my $self = shift;
    my ( $start_state, $symbol, $next_state ) = @_;

    my $hooks_list =
        $self->{hooks}{$start_state}{$symbol} // [];

    return $hooks_list;
}

sub process {
    my $self = shift;
    my ($string) = @_;

    my $l = length($string);

    for my $col ( 0 .. ($l-1) ) {
        my $symbol = substr( $string, $col, 1 );

        my $current_state = $self->{current_state};
        my $next_state    = $self->{transitions}{$current_state}{$symbol};


        # we could not move to the next stage.
        return $self->{error_callback}->($col, $self->{args},)
            unless defined $next_state;

        # resolve dynamic names
        $next_state = $next_state->($symbol)
            if ref $next_state eq 'CODE';

        # print Dumper {
        #     c => $current_state,
        #     n => $next_state,
        #     s => $symbol,
        # };
        # call defined hooks
        my $hooks = $self->get_hooks(
            $current_state,
            $symbol,
            $next_state,
        );
        for my $hook (@{$hooks}) {
            $hook->(
                $current_state,
                $symbol,
                $next_state,
                $col,
                $self->{args},
            );
        }

        $self->{current_state} = $next_state;
    }

    # we are done recognizing the string, everything went smoothly
    return 0;
}

1;