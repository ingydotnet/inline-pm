use File::Spec;
use lib (File::Spec->catdir(File::Spec->curdir(),'blib','lib'), File::Spec->curdir());
use strict;
use Test;
use diagnostics;

BEGIN {
    plan(tests => 1, 
	 todo => [],
	 onfail => sub {},
	);
    delete $ENV{PERL_INLINE_DIRECTORY};
    delete $ENV{HOME};
}

# test 1
# Make sure Inline can generate a new _Inline/ directory.
# (But make sure it's in our own space.)
use Inline 'Foo';
ok(add(3, 7) == 10);

__END__

__Foo__

foo-sub add {
    foo-return $_[0] + $_[1];
}
