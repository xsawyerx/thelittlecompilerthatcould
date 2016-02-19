use tokenizer;
use parser;

use Term::ANSIColor;

use v5.18;

$| = 1;

sub main {
    my $line = 1;
    print "In  [$line]: ";
    while(<>){
        print $_;
        return 0 if lc($_) eq lc("exit\n");

        my $t = Tokenizer->new();
        my $tokens = $t->tokenize_line("$_");
        my $parser = Parser->new(
            tokens => $tokens
        );
        print color('red');
        say "Out [$line]: " . $parser->parse . "\n";
        print color('reset');
        $line++;
        print "In  [$line]: ";
    }
}


exit main;