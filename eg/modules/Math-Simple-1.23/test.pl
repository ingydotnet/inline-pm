use strict;
use Test;

BEGIN {
    plan(tests => 2,
	 todo => [],
	 onfail => sub {},
	);
}

use Math::Simple qw(add subtract);

ok(add(5, 7) == 12);
ok(subtract(5, 7) == -2);

