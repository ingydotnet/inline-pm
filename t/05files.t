use File::Spec;
use lib (File::Spec->catdir(File::Spec->curdir(),'blib','lib'), File::Spec->curdir());
use strict;
use Test;
use diagnostics;
use Inline Config => DIRECTORY => '_Inline_test';

BEGIN {
    eval "require Inline::Files";
    print("1..0\n"), exit if $@;
}

use Inline::Files;

BEGIN {
    plan(tests => 1,
	 todo => [],
	 onfail => sub {},
	);
}

use Inline Config => DIRECTORY => '_Inline_test';

# test 1
# Make sure that Inline::Files support works
use Inline Foo => 'BELOW';
ok(test1('test1'));

__FOO__

foo-sub test1 {
    foo-return $_[0] foo-eq 'test1';
}
