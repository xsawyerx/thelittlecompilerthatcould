package Tokenizer;

use v5.18;

use strict;
use warnings;

use finite_state_machine;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Indent   = 1;
$Data::Dumper::Terse    = 1;

our $ops = {
        '!'   => 'OP_BOOL_NOT',
        '!='  => 'OP_BOOL_NOT_SET',
        '%'   => 'OP_MODULO',
        '%='  => 'OP_MODULO_SET',
        '&&'  => 'OP_BOOL_AND',
        '&&=' => 'OP_BOOL_AND_SET',
        '&'   => 'OP_AND',
        '&='  => 'OP_AND_SET',
        '*'   => 'OP_MULTIPLY',
        '**'  => 'OP_POWER',
        '**=' => 'OP_POWER_SET',
        '*='  => 'OP_MULTIPLY_SET',
        '+'   => 'OP_ADD',
        '+='  => 'OP_ADD_SET',
        '-'   => 'OP_SUBTRACT',
        '-='  => 'OP_SUBTRACT_SET',
        '.'   => 'OP_GETATTR',
        '/'   => 'OP_DIVIDE',
        '//'  => 'OP_INT_DIVIDE',
        '/='  => 'OP_DIVIDE_SET',
        ':'   => 'OP_ELSE',
        '<'   => 'OP_LT',
        '<<'  => 'OP_SHIFT_LEFT',
        '<<=' => 'OP_SHIFT_LEFT_SET',
        '<='  => 'OP_LE',
        '<>'  => 'OP_NE',
        '='   => 'OP_SET',
        '=='  => 'OP_EQ',
        '>'   => 'OP_GT',
        '>='  => 'OP_GE',
        '>>'  => 'OP_SHIFT_RIGHT',
        '>>=' => 'OP_SHIFT_RIGHT_SET',
        '?'   => 'OP_IF',
        '^'   => 'OP_XOR',
        '^='  => 'OP_XOR_SET',
        '|'   => 'OP_OR',
        '|='  => 'OP_OR_SET',
        '||'  => 'OP_BOOL_OR',
        '||=' => 'OP_BOOL_OR_SET',
        '~'   => 'OP_NOT',
        '~='  => 'OP_NOT_SET',
    };

# list of all accepted tokens
sub language_definition {
    [
        ['WS'   => ['(']              => '('       ],
        ['WS'   => ['\d']             => 'INT'     ],
        ['WS'   => ['\a', '_']        => 'NAME'    ],
        ['WS'   => ['\op']            => \&name_op ],
        ['WS'   => ['\s']             => 'WS'      ],
        ['WS'   => [')']              => ')'       ],

        ['INT'  => ['\d']             => 'INT'     ],
        ['INT'  => ['\op']            => \&name_op ],
        ['INT'  => [')']              => ')'       ],
        ['INT'  => ['\s']             => 'WS'      ],

        ['NAME' => ['\w']             => 'NAME'    ],
        ['NAME' => ['\op']            => \&name_op ],
        ['NAME' => [')']              => ')'       ],
        ['NAME' => ['\s']             => 'WS'      ],

        ['('    => ['\a', '_']        => 'NAME'    ],
        ['('    => ['\d']             => 'INT'     ],
        ['('    => ['(']              => '('       ],
        ['('    => ['\s']             => 'WS'      ],

        [')'    => ['\op']            => \&name_op ],
        [')'    => [')']              => ')'       ],
        [')'    => ['\s']             => 'WS'      ],

        ['!'    => ['\a', '_']        => 'NAME'    ],
        ['!'    => ['\d']             => 'INT'     ],
        ['!'    => ['(']              => '('       ],
        ['!'    => ['=']              => '!='      ],
        ['!'    => ['!']              => '!'       ],
        ['!'    => ['\s']             => 'WS'      ],
        ['!='   => ['\a', '_']        => 'NAME'    ],
        ['!='   => ['\d']             => 'INT'     ],
        ['!='   => ['(']              => '('       ],
        ['!='   => ['\s']             => 'WS'      ],
        ['%'    => ['\a', '_']        => 'NAME'    ],
        ['%'    => ['\d']             => 'INT'     ],
        ['%'    => ['(']              => '('       ],
        ['%'    => ['=']              => '%='      ],
        ['%'    => ['\s']             => 'WS'      ],
        ['%='   => ['\a', '_']        => 'NAME'    ],
        ['%='   => ['\d']             => 'INT'     ],
        ['%='   => ['(']              => '('       ],
        ['%='   => ['\s']             => 'WS'      ],
        ['&'    => ['\a', '_']        => 'NAME'    ],
        ['&'    => ['\d']             => 'INT'     ],
        ['&'    => ['(']              => '('       ],
        ['&'    => ['&']              => '&&'      ],
        ['&'    => ['=']              => '&='      ],
        ['&'    => ['\s']             => 'WS'      ],
        ['&&'   => ['\a', '_']        => 'NAME'    ],
        ['&&'   => ['\d']             => 'INT'     ],
        ['&&'   => ['(']              => '('       ],
        ['&&'   => ['=']              => '&&='     ],
        ['&&'   => ['\s']             => 'WS'      ],
        ['&='   => ['\a', '_']        => 'NAME'    ],
        ['&='   => ['\d']             => 'INT'     ],
        ['&='   => ['(']              => '('       ],
        ['&='   => ['\s']             => 'WS'      ],
        ['&&='  => ['\a', '_']        => 'NAME'    ],
        ['&&='  => ['\d']             => 'INT'     ],
        ['&&='  => ['(']              => '('       ],
        ['&&='  => ['\s']             => 'WS'      ],
        ['*'    => ['\a', '_']        => 'NAME'    ],
        ['*'    => ['\d']             => 'INT'     ],
        ['*'    => ['(']              => '('       ],
        ['*'    => ['=']              => '*='      ],
        ['*'    => ['*']              => '**'      ],
        ['*'    => ['\s']             => 'WS'      ],
        ['*='   => ['\a', '_']        => 'NAME'    ],
        ['*='   => ['\d']             => 'INT'     ],
        ['*='   => ['(']              => '('       ],
        ['*='   => ['\s']             => 'WS'      ],
        ['**'   => ['\a', '_']        => 'NAME'    ],
        ['**'   => ['\d']             => 'INT'     ],
        ['**'   => ['(']              => '('       ],
        ['**'   => ['=']              => '**='     ],
        ['**'   => ['\s']             => 'WS'      ],
        ['**='  => ['\a', '_']        => 'NAME'    ],
        ['**='  => ['\d']             => 'INT'     ],
        ['**='  => ['(']              => '('       ],
        ['**='  => ['\s']             => 'WS'      ],
        ['+'    => ['\a', '_']        => 'NAME'    ],
        ['+'    => ['\d']             => 'INT'     ],
        ['+'    => ['(']              => '('       ],
        ['+'    => ['=']              => '+='      ],
        ['+'    => ['\s']             => 'WS'      ],
        ['+='   => ['\a', '_']        => 'NAME'    ],
        ['+='   => ['\d']             => 'INT'     ],
        ['+='   => ['(']              => '('       ],
        ['+='   => ['\s']             => 'WS'      ],
        ['-'    => ['\a', '_']        => 'NAME'    ],
        ['-'    => ['\d']             => 'INT'     ],
        ['-'    => ['(']              => '('       ],
        ['-'    => ['=']              => '-='      ],
        ['-'    => ['\s']             => 'WS'      ],
        ['-='   => ['\a', '_']        => 'NAME'    ],
        ['-='   => ['\d']             => 'INT'     ],
        ['-='   => ['(']              => '('       ],
        ['-='   => ['\s']             => 'WS'      ],
        ['.'    => ['\a', '_']        => 'NAME'    ],
        ['.'    => ['\d']             => 'INT'     ],
        ['.'    => ['(']              => '('       ],
        ['.'    => ['\s']             => 'WS'      ],
        ['/'    => ['\a', '_']        => 'NAME'    ],
        ['/'    => ['\d']             => 'INT'     ],
        ['/'    => ['(']              => '('       ],
        ['/'    => ['=']              => '/='      ],
        ['/'    => ['/']              => '//'      ],
        ['/'    => ['\s']             => 'WS'      ],
        ['/='   => ['\a', '_']        => 'NAME'    ],
        ['/='   => ['\d']             => 'INT'     ],
        ['/='   => ['(']              => '('       ],
        ['/='   => ['\s']             => 'WS'      ],
        [':'    => ['\a', '_']        => 'NAME'    ],
        [':'    => ['\d']             => 'INT'     ],
        [':'    => ['(']              => '('       ],
        [':'    => ['\s']             => 'WS'      ],
        ['<'    => ['\a', '_']        => 'NAME'    ],
        ['<'    => ['\d']             => 'INT'     ],
        ['<'    => ['(']              => '('       ],
        ['<'    => ['<']              => '<<'      ],
        ['<'    => ['=']              => '<='      ],
        ['<'    => ['>']              => '<>'      ],
        ['<'    => ['\s']             => 'WS'      ],
        ['<<'   => ['\a', '_']        => 'NAME'    ],
        ['<<'   => ['\d']             => 'INT'     ],
        ['<<'   => ['(']              => '('       ],
        ['<<'   => ['=']              => '<<='     ],
        ['<<'   => ['\s']             => 'WS'      ],
        ['<<='  => ['\a', '_']        => 'NAME'    ],
        ['<<='  => ['\d']             => 'INT'     ],
        ['<<='  => ['(']              => '('       ],
        ['<<='  => ['\s']             => 'WS'      ],
        ['<='   => ['\a', '_']        => 'NAME'    ],
        ['<='   => ['\d']             => 'INT'     ],
        ['<='   => ['(']              => '('       ],
        ['<='   => ['\s']             => 'WS'      ],
        ['<>'   => ['\a', '_']        => 'NAME'    ],
        ['<>'   => ['\d']             => 'INT'     ],
        ['<>'   => ['(']              => '('       ],
        ['<>'   => ['\s']             => 'WS'      ],
        ['='    => ['\a', '_']        => 'NAME'    ],
        ['='    => ['\d']             => 'INT'     ],
        ['='    => ['(']              => '('       ],
        ['='    => ['=']              => '=='      ],
        ['='    => ['\s']             => 'WS'      ],
        ['=='   => ['\a', '_']        => 'NAME'    ],
        ['=='   => ['\d']             => 'INT'     ],
        ['=='   => ['(']              => '('       ],
        ['=='   => ['\s']             => 'WS'      ],
        ['>'    => ['\a', '_']        => 'NAME'    ],
        ['>'    => ['\d']             => 'INT'     ],
        ['>'    => ['(']              => '('       ],
        ['>'    => ['>']              => '>>'      ],
        ['>'    => ['=']              => '>='      ],
        ['>'    => ['\s']             => 'WS'      ],
        ['>='   => ['\a', '_']        => 'NAME'    ],
        ['>='   => ['\d']             => 'INT'     ],
        ['>='   => ['(']              => '('       ],
        ['>='   => ['\s']             => 'WS'      ],
        ['>>'   => ['\a', '_']        => 'NAME'    ],
        ['>>'   => ['\d']             => 'INT'     ],
        ['>>'   => ['(']              => '('       ],
        ['>>'   => ['=']              => '>>='     ],
        ['>>'   => ['\s']             => 'WS'      ],
        ['>>='  => ['\a', '_']        => 'NAME'    ],
        ['>>='  => ['\d']             => 'INT'     ],
        ['>>='  => ['(']              => '('       ],
        ['>>='  => ['\s']             => 'WS'      ],
        ['?'    => ['\a', '_']        => 'NAME'    ],
        ['?'    => ['\d']             => 'INT'     ],
        ['?'    => ['(']              => '('       ],
        ['?'    => ['\s']             => 'WS'      ],
        ['^'    => ['\a', '_']        => 'NAME'    ],
        ['^'    => ['\d']             => 'INT'     ],
        ['^'    => ['(']              => '('       ],
        ['^'    => ['=']              => '^='      ],
        ['^'    => ['\s']             => 'WS'      ],
        ['^='   => ['\a', '_']        => 'NAME'    ],
        ['^='   => ['\d']             => 'INT'     ],
        ['^='   => ['(']              => '('       ],
        ['^='   => ['\s']             => 'WS'      ],
        ['|'    => ['\a', '_']        => 'NAME'    ],
        ['|'    => ['\d']             => 'INT'     ],
        ['|'    => ['(']              => '('       ],
        ['|'    => ['|']              => '||'      ],
        ['|'    => ['=']              => '|='      ],
        ['|'    => ['\s']             => 'WS'      ],
        ['|='   => ['\a', '_']        => 'NAME'    ],
        ['|='   => ['\d']             => 'INT'     ],
        ['|='   => ['(']              => '('       ],
        ['|='   => ['\s']             => 'WS'      ],
        ['||'   => ['\a', '_']        => 'NAME'    ],
        ['||'   => ['\d']             => 'INT'     ],
        ['||'   => ['(']              => '('       ],
        ['||'   => ['=']              => '||='     ],
        ['||'   => ['\s']             => 'WS'      ],
        ['||='  => ['\a', '_']        => 'NAME'    ],
        ['||='  => ['\d']             => 'INT'     ],
        ['||='  => ['(']              => '('       ],
        ['||='  => ['\s']             => 'WS'      ],
        ['~'    => ['\a', '_']        => 'NAME'    ],
        ['~'    => ['\d']             => 'INT'     ],
        ['~'    => ['(']              => '('       ],
        ['~'    => ['~']              => '~'       ],
        ['~'    => ['=']              => '~='      ],
        ['~'    => ['\s']             => 'WS'      ],
        ['~='   => ['\a', '_']        => 'NAME'    ],
        ['~='   => ['\d']             => 'INT'     ],
        ['~='   => ['(']              => '('       ],
        ['~='   => ['\s']             => 'WS'      ],
    ];
}

sub hooks {
    [
        # First we fetch the values
        ['INT'  => ['\op']     => \&name_op => \&fetch_integer     ],
        ['INT'  => [')']       => ')'       => \&fetch_integer     ],
        ['INT'  => ['\s']      => 'WS'      => \&fetch_integer     ],
        ['NAME' => ['\op']     => \&name_op => \&fetch_name        ],
        ['NAME' => [')']       => ')'       => \&fetch_name        ],
        ['NAME' => ['\s']      => 'WS'      => \&fetch_name        ],
        ['('    => ['\a', '_'] => 'NAME'    => \&fetch_parenthesis ],
        ['('    => ['\d']      => 'INT'     => \&fetch_parenthesis ],
        ['('    => ['\s']      => 'WS'      => \&fetch_parenthesis ],
        ['('    => ['(']       => '('       => \&fetch_parenthesis ],
        [')'    => ['\op']     => \&name_op => \&fetch_parenthesis ],
        [')'    => ['\s']      => 'WS'      => \&fetch_parenthesis ],
        [')'    => [')']       => ')'       => \&fetch_parenthesis ],
        ['!'    => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['!'    => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['!'    => ['(']       => '('       => \&fetch_operator    ],
        ['!'    => ['!']       => '!'       => \&fetch_operator    ],
        ['!'    => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['!='   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['!='   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['!='   => ['(']       => '('       => \&fetch_operator    ],
        ['!='   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['%'    => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['%'    => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['%'    => ['(']       => '('       => \&fetch_operator    ],
        ['%'    => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['%='   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['%='   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['%='   => ['(']       => '('       => \&fetch_operator    ],
        ['%='   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['&'    => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['&'    => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['&'    => ['(']       => '('       => \&fetch_operator    ],
        ['&'    => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['&&'   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['&&'   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['&&'   => ['(']       => '('       => \&fetch_operator    ],
        ['&&'   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['&='   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['&='   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['&='   => ['(']       => '('       => \&fetch_operator    ],
        ['&='   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['&&='  => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['&&='  => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['&&='  => ['(']       => '('       => \&fetch_operator    ],
        ['&&='  => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['*'    => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['*'    => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['*'    => ['(']       => '('       => \&fetch_operator    ],
        ['*'    => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['*='   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['*='   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['*='   => ['(']       => '('       => \&fetch_operator    ],
        ['*='   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['**'   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['**'   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['**'   => ['(']       => '('       => \&fetch_operator    ],
        ['**'   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['**='  => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['**='  => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['**='  => ['(']       => '('       => \&fetch_operator    ],
        ['**='  => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['+'    => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['+'    => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['+'    => ['(']       => '('       => \&fetch_operator    ],
        ['+'    => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['+='   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['+='   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['+='   => ['(']       => '('       => \&fetch_operator    ],
        ['+='   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['-'    => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['-'    => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['-'    => ['(']       => '('       => \&fetch_operator    ],
        ['-'    => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['-='   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['-='   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['-='   => ['(']       => '('       => \&fetch_operator    ],
        ['-='   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['.'    => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['.'    => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['.'    => ['(']       => '('       => \&fetch_operator    ],
        ['.'    => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['/'    => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['/'    => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['/'    => ['(']       => '('       => \&fetch_operator    ],
        ['/'    => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['//'   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['//'   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['//'   => ['(']       => '('       => \&fetch_operator    ],
        ['//'   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['/='   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['/='   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['/='   => ['(']       => '('       => \&fetch_operator    ],
        ['/='   => ['\s']      => 'WS'      => \&fetch_operator    ],
        [':'    => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        [':'    => ['\d']      => 'INT'     => \&fetch_operator    ],
        [':'    => ['(']       => '('       => \&fetch_operator    ],
        [':'    => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['<'    => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['<'    => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['<'    => ['(']       => '('       => \&fetch_operator    ],
        ['<'    => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['<<'   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['<<'   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['<<'   => ['(']       => '('       => \&fetch_operator    ],
        ['<<'   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['<<='  => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['<<='  => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['<<='  => ['(']       => '('       => \&fetch_operator    ],
        ['<<='  => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['<='   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['<='   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['<='   => ['(']       => '('       => \&fetch_operator    ],
        ['<='   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['<>'   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['<>'   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['<>'   => ['(']       => '('       => \&fetch_operator    ],
        ['<>'   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['='    => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['='    => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['='    => ['(']       => '('       => \&fetch_operator    ],
        ['='    => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['=='   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['=='   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['=='   => ['(']       => '('       => \&fetch_operator    ],
        ['=='   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['>'    => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['>'    => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['>'    => ['(']       => '('       => \&fetch_operator    ],
        ['>'    => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['>='   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['>='   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['>='   => ['(']       => '('       => \&fetch_operator    ],
        ['>='   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['>>'   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['>>'   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['>>'   => ['(']       => '('       => \&fetch_operator    ],
        ['>>'   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['>>='  => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['>>='  => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['>>='  => ['(']       => '('       => \&fetch_operator    ],
        ['>>='  => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['?'    => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['?'    => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['?'    => ['(']       => '('       => \&fetch_operator    ],
        ['?'    => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['^'    => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['^'    => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['^'    => ['(']       => '('       => \&fetch_operator    ],
        ['^'    => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['^='   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['^='   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['^='   => ['(']       => '('       => \&fetch_operator    ],
        ['^='   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['|'    => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['|'    => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['|'    => ['(']       => '('       => \&fetch_operator    ],
        ['|'    => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['|='   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['|='   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['|='   => ['(']       => '('       => \&fetch_operator    ],
        ['|='   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['||'   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['||'   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['||'   => ['(']       => '('       => \&fetch_operator    ],
        ['||'   => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['||='  => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['||='  => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['||='  => ['(']       => '('       => \&fetch_operator    ],
        ['||='  => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['~'    => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['~'    => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['~'    => ['(']       => '('       => \&fetch_operator    ],
        ['~'    => ['~']       => '~'       => \&fetch_operator    ],
        ['~'    => ['\s']      => 'WS'      => \&fetch_operator    ],
        ['~='   => ['\a', '_'] => 'NAME'    => \&fetch_operator    ],
        ['~='   => ['\d']      => 'INT'     => \&fetch_operator    ],
        ['~='   => ['(']       => '('       => \&fetch_operator    ],
        ['~='   => ['\s']      => 'WS'      => \&fetch_operator    ],

        # Then we start a new token
        ['WS'   => ['(']       => '('       => \&start_token       ],
        ['WS'   => [')']       => ')'       => \&start_token       ],
        ['WS'   => ['\d']      => 'INT'     => \&start_token       ],
        ['WS'   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['WS'   => ['\op']     => \&name_op => \&start_token       ],
        ['INT'  => ['\op']     => \&name_op => \&start_token       ],
        ['INT'  => [')']       => ')'       => \&start_token       ],
        ['NAME' => ['\op']     => \&name_op => \&start_token       ],
        ['NAME' => [')']       => ')'       => \&start_token       ],
        ['('    => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['('    => ['\d']      => 'INT'     => \&start_token       ],
        ['('    => ['(']       => '('       => \&start_token       ],
        [')'    => ['\op']     => \&name_op => \&start_token       ],
        [')'    => [')']       => ')'       => \&start_token       ],
        ['!'    => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['!'    => ['\d']      => 'INT'     => \&start_token       ],
        ['!'    => ['(']       => '('       => \&start_token       ],
        ['!'    => ['!']       => '!'       => \&start_token       ],
        ['!='   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['!='   => ['\d']      => 'INT'     => \&start_token       ],
        ['!='   => ['(']       => '('       => \&start_token       ],
        ['%'    => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['%'    => ['\d']      => 'INT'     => \&start_token       ],
        ['%'    => ['(']       => '('       => \&start_token       ],
        ['%='   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['%='   => ['\d']      => 'INT'     => \&start_token       ],
        ['%='   => ['(']       => '('       => \&start_token       ],
        ['&'    => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['&'    => ['\d']      => 'INT'     => \&start_token       ],
        ['&'    => ['(']       => '('       => \&start_token       ],
        ['&&'   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['&&'   => ['\d']      => 'INT'     => \&start_token       ],
        ['&&'   => ['(']       => '('       => \&start_token       ],
        ['&='   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['&='   => ['\d']      => 'INT'     => \&start_token       ],
        ['&='   => ['(']       => '('       => \&start_token       ],
        ['&&='  => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['&&='  => ['\d']      => 'INT'     => \&start_token       ],
        ['&&='  => ['(']       => '('       => \&start_token       ],
        ['*'    => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['*'    => ['\d']      => 'INT'     => \&start_token       ],
        ['*'    => ['(']       => '('       => \&start_token       ],
        ['*='   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['*='   => ['\d']      => 'INT'     => \&start_token       ],
        ['*='   => ['(']       => '('       => \&start_token       ],
        ['**'   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['**'   => ['\d']      => 'INT'     => \&start_token       ],
        ['**'   => ['(']       => '('       => \&start_token       ],
        ['**='  => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['**='  => ['\d']      => 'INT'     => \&start_token       ],
        ['**='  => ['(']       => '('       => \&start_token       ],
        ['+'    => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['+'    => ['\d']      => 'INT'     => \&start_token       ],
        ['+'    => ['(']       => '('       => \&start_token       ],
        ['+='   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['+='   => ['\d']      => 'INT'     => \&start_token       ],
        ['+='   => ['(']       => '('       => \&start_token       ],
        ['-'    => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['-'    => ['\d']      => 'INT'     => \&start_token       ],
        ['-'    => ['(']       => '('       => \&start_token       ],
        ['-='   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['-='   => ['\d']      => 'INT'     => \&start_token       ],
        ['-='   => ['(']       => '('       => \&start_token       ],
        ['.'    => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['.'    => ['\d']      => 'INT'     => \&start_token       ],
        ['.'    => ['(']       => '('       => \&start_token       ],
        ['/'    => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['/'    => ['\d']      => 'INT'     => \&start_token       ],
        ['/'    => ['(']       => '('       => \&start_token       ],
        ['//'   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['//'   => ['\d']      => 'INT'     => \&start_token       ],
        ['//'   => ['(']       => '('       => \&start_token       ],
        ['/='   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['/='   => ['\d']      => 'INT'     => \&start_token       ],
        ['/='   => ['(']       => '('       => \&start_token       ],
        [':'    => ['\a', '_'] => 'NAME'    => \&start_token       ],
        [':'    => ['\d']      => 'INT'     => \&start_token       ],
        [':'    => ['(']       => '('       => \&start_token       ],
        ['<'    => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['<'    => ['\d']      => 'INT'     => \&start_token       ],
        ['<'    => ['(']       => '('       => \&start_token       ],
        ['<<'   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['<<'   => ['\d']      => 'INT'     => \&start_token       ],
        ['<<'   => ['(']       => '('       => \&start_token       ],
        ['<<='  => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['<<='  => ['\d']      => 'INT'     => \&start_token       ],
        ['<<='  => ['(']       => '('       => \&start_token       ],
        ['<='   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['<='   => ['\d']      => 'INT'     => \&start_token       ],
        ['<='   => ['(']       => '('       => \&start_token       ],
        ['<>'   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['<>'   => ['\d']      => 'INT'     => \&start_token       ],
        ['<>'   => ['(']       => '('       => \&start_token       ],
        ['='    => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['='    => ['\d']      => 'INT'     => \&start_token       ],
        ['='    => ['(']       => '('       => \&start_token       ],
        ['=='   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['=='   => ['\d']      => 'INT'     => \&start_token       ],
        ['=='   => ['(']       => '('       => \&start_token       ],
        ['>'    => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['>'    => ['\d']      => 'INT'     => \&start_token       ],
        ['>'    => ['(']       => '('       => \&start_token       ],
        ['>='   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['>='   => ['\d']      => 'INT'     => \&start_token       ],
        ['>='   => ['(']       => '('       => \&start_token       ],
        ['>>'   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['>>'   => ['\d']      => 'INT'     => \&start_token       ],
        ['>>'   => ['(']       => '('       => \&start_token       ],
        ['>>='  => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['>>='  => ['\d']      => 'INT'     => \&start_token       ],
        ['>>='  => ['(']       => '('       => \&start_token       ],
        ['?'    => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['?'    => ['\d']      => 'INT'     => \&start_token       ],
        ['?'    => ['(']       => '('       => \&start_token       ],
        ['^'    => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['^'    => ['\d']      => 'INT'     => \&start_token       ],
        ['^'    => ['(']       => '('       => \&start_token       ],
        ['^='   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['^='   => ['\d']      => 'INT'     => \&start_token       ],
        ['^='   => ['(']       => '('       => \&start_token       ],
        ['|'    => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['|'    => ['\d']      => 'INT'     => \&start_token       ],
        ['|'    => ['(']       => '('       => \&start_token       ],
        ['|='   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['|='   => ['\d']      => 'INT'     => \&start_token       ],
        ['|='   => ['(']       => '('       => \&start_token       ],
        ['||'   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['||'   => ['\d']      => 'INT'     => \&start_token       ],
        ['||'   => ['(']       => '('       => \&start_token       ],
        ['||='  => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['||='  => ['\d']      => 'INT'     => \&start_token       ],
        ['||='  => ['(']       => '('       => \&start_token       ],
        ['~'    => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['~'    => ['\d']      => 'INT'     => \&start_token       ],
        ['~'    => ['(']       => '('       => \&start_token       ],
        ['~'    => ['~']       => '~'       => \&start_token       ],
        ['~='   => ['\a', '_'] => 'NAME'    => \&start_token       ],
        ['~='   => ['\d']      => 'INT'     => \&start_token       ],
        ['~='   => ['(']       => '('       => \&start_token       ],
    ];
};


sub new {
    my $class = shift;

    my $token_list = [];
    my $fsm = FiniteStateMachine->new(
        initial_state  => 'WS',
        args           => { token_list => $token_list },
        error_callback => \&error,
    );

    $fsm->add_metachar('\op' => [qw(+ - * / ^ & | ~ = . ? % < > !)]);
    $fsm->add_transition_list($class->language_definition);
    $fsm->add_transition_list($class->hooks);

    my $self = {
        fsm        => $fsm,
        token_list => $token_list,
    };

    return bless $self => $class;
}

sub error {
    my ( $col, $args ) = @_;

    $col //= 0;

    my $line_index = $args->{line_index} // 0;
    my $line       = $args->{line};
    my $example    = substr($line, $col, 3);

    die "Syntax error at line $line_index, $col near '$example'\n";
}

sub tokenize {
    my $self = shift;

    my @lines = @_;
    return map { @{ $self->tokenize_line( $lines[$_], $_ ) } } 0 .. @lines;
}

sub tokenize_line {
    my $self = shift;
    my ( $line, $line_index ) = @_;

    $self->{fsm}->reset();
    $self->{fsm}{args}{line}       = $line;
    $self->{fsm}{args}{line_index} = $line_index // 0;

    $self->{fsm}->process($line);

    # add an of line symbol
    push $self->{token_list} => { type => 'ENDL' };

    return $self->{token_list};
}

sub name_op {
    my ( $symbol ) = @_;
    return $symbol;
}

sub start_token {
    my ($current_state, $symbol, $next_state, $col, $args,) = @_;

    $args->{start_col}  = $col;
}

sub fetch_seperator {
    my ($current_state, $symbol, $next_state, $col, $args,) = @_;

    my $line       = $args->{line};
    my $token_list = $args->{token_list};

    if ( $symbol eq ';' || $symbol eq "\n" )  {
        push $token_list, '(ENDL)';
    }
    if ( $symbol eq ',' ) {
        push $token_list, '(COMMA)';
    }
}

sub fetch_integer {
    my ($current_state, $symbol, $next_state, $col, $args,) = @_;

    my $token_list = $args->{token_list};
    my $line       = $args->{line};

    my $start = $args->{start_col};
    my $len   = $col - $start;
    my $value = substr($line, $start, $len);

    push $token_list, { type => 'INTEGER', value => $value };
}

sub fetch_name {
    my ($current_state, $symbol, $next_state, $col, $args,) = @_;

    my $token_list = $args->{token_list};
    my $line       = $args->{line};

    my $start = $args->{start_col};
    my $len   = $col - $start;
    my $value = substr($line, $start, $len);

    my $names = {
        'function' => ("FUNCTION_DEF"),
        'endf'     => ("FUNCTION_END"),
        'if'       => ("IF"),
        'else'     => ("ELSE"),
        'elif'     => ("ELIF"),
        'endif'    => ("ENDIF"),
        'for'      => ("FOR"),
        'while'    => ("WHILE"),
        'break'    => ("BREAK"),
        'next'     => ("NEXT"),
        'done'     => ("DONE"),
    };

    my $name = $names->{$value};
    my $token  = defined $name
        ? { type => $name }
        : { type => 'NAME', $value => $value };

    push $token_list, $token;
}

sub fetch_string {
    my ($current_state, $symbol, $next_state, $col, $args,) = @_;

    my $token_list = $args->{token_list};
    my $line       = $args->{line};

    my $start = $args->{start_col};
    my $len   = $col - $start;
    my $value = substr($line, $start, $len);

    push $token_list, { type => 'STRING', value => $value };
}

sub fetch_parenthesis {
    my ($current_state, $symbol, $next_state, $col, $args,) = @_;

    my $token_list = $args->{token_list};

    my $line       = $args->{line};

    my $start = $args->{start_col};
    my $len   = $col - $start;
    my $value = substr($line, $start, $len);

    my $parenthesis = {
        '(' => 'OPEN_PARENTHESIS',
        ')' => 'CLOSE_PARENTHESIS',
    };

    push $token_list, { type => $parenthesis->{$value} };
}

sub fetch_operator {
    my ($current_state, $symbol, $next_state, $col, $args,) = @_;

    my $token_list = $args->{token_list};
    my $line       = $args->{line};

    my $start = $args->{start_col};
    my $len   = $col - $start;
    my $value = substr($line, $start, $len);

    my $op = $ops->{$value};
    push $token_list, { type => $op };
}

sub __TEST__ {
    my @lines = split "\n", << "    ---";
        function hello_world
            a = 1 + 2 * ( 3 / 4 + 5 ) + 6 * 7 + 8
            b = 1+ 2 *( 3/ 4 + 5) +6 * 7 + 8
        endf
    ---
    for my $line ( @lines ) {
        my $t = Tokenizer->new();
        print Dumper $t->tokenize_line("$line\n");
    }

}

1;