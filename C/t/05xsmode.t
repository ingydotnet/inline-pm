use lib qw(../blib/lib ./blib/lib);
use strict;
use Test;
use diagnostics;
use Inline Config => DIRECTORY => './_Inline_test';

BEGIN {
    plan(tests => 1,
	 todo => [],
	 onfail => sub {},
	);
}

use Inline C => DATA =>
           ENABLE => XSMODE =>
           NAME => 'xsmode';

# test 1
ok(add(5, 10) == 15);

__END__

__C__

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

MODULE = xsmode      PACKAGE = main

int
add (x, y)
        int     x
        int     y
    CODE:
        RETVAL = x + y;
    OUTPUT:
        RETVAL
