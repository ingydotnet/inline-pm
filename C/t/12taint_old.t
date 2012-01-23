#!perl -T

BEGIN {
  if($] >= 5.007) {
    print "1..1\n";
    warn "Skipped - applies only to perl 5.6.x\n";
    print "ok 1\n";
    exit(0);
  }
};

BEGIN {
  if (exists $ENV{PERL_INSTALL_ROOT}) {
    warn "\nIgnoring \$ENV{PERL_INSTALL_ROOT} in $0\n";
    delete $ENV{PERL_INSTALL_ROOT};
  }
};

use File::Spec;
use lib (File::Spec->catdir(File::Spec->updir(),'blib','lib'), File::Spec->catdir(File::Spec->curdir(),'blib','lib'));
use strict;
use Test;
use diagnostics;
use Inline Config =>
    UNTAINT => 1,
    DIRECTORY => '_Inline_test';

BEGIN {
    plan(tests => 5,
	 todo => [],
	 onfail => sub {},
	);
    warn "Expect a number of \"Blindly untainting ...\" warnings - these are intended.\n";
}
use Inline Config =>
           UNTAINT => 1,
           DIRECTORY => '_Inline_test';

# test 1 - Check string syntax
ok(add(3, 7) == 10);
# test 2 - Check string syntax again
ok(subtract(3, 7) == -4);
# test 3 - Check DATA syntax
ok(multiply(3, 7) == 21);
# test 4 - Check DATA syntax again
ok(divide(7, -3) == -2);

use Inline 'C';
use Inline C => 'DATA';
use Inline C => <<'END_OF_C_CODE';

int add(int x, int y) {
    return x + y;
}

int subtract(int x, int y) {
    return x - y;
}
END_OF_C_CODE

Inline->bind(C => <<'END');

int incr(int x) {
    return x + 1;
}
END

# test 5 - Test Inline->bind() syntax
ok(incr(incr(7)) == 9);

__END__

# unused code or maybe AutoLoader stuff
sub crap {
    return 'crap';
}

__C__

int multiply(int x, int y) {
    return x * y;
}

__C__

int divide(int x, int y) {
    return x / y;
}
