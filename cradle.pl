#!/usr/bin/perl
use Lib::Utils::CheckType qw(is_digit);
my $look = '';

sub getchar {
	$look = getc(STDIN);
}

sub get_num {
	my $ret = $look;
	if (!is_digit($look)) {
		print "Error!";
	}

	getchar();

	return $ret;
}

sub match {
	my $char = shift;
	if ($look eq $char) {
		getchar();
	} else {
		print "Expected $char\n";
	}
}

sub init {
    getchar();
}

sub is_addop {
	my $char = shift;
	return $char =~m/[+-]/;
}

sub multiply {
	match('*');
	factor();
	print "muls (sp)+, D0\n";
}

sub divide {
	match('/');
	factor();
	print "MOVE (sp)+, D1\n";
	print "DIVS D1, D0";
}

sub term {
	factor();
	while ($look eq '*' || $look eq '/') {
		print "MOVE D0,-(SP)\n";
		if ($look eq '*') {
			multiply();
		} elsif ($look eq '/') {
			divide();
		}
		else {
			print "Expected Mulop";
		}
	}
}

sub add {
	match("+");
	term();
	print "ADD (SP)+, D0\n";
}

sub subtract {
	match("-");
	term();
	print "SUB (SP)+, D0\n";
	print "NEG D0\n";
}

sub factor {
	if ($look eq '(') {
		match('(');
		expression();
		match(')');
	} else {
		printf "MOVE #" . get_num . ', D0\n';
	}
}

sub expression {
	if (is_addop($look)) {
		print "CLR D0";
	} else {
		term();
	}

	while (is_addop($look)) {
    	print "MOVE D0,-(SP)";
      	if ($look eq '+') {
      		add();
      	} elsif ($look eq '-') {
      		subtract();
      	}
      	else {
      		print "Expected Addop\n";
      	}
   	}

}


init();
expression();
print "\n";