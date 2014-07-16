use strict; use warnings;
use File::Basename;
use lib dirname(__FILE__);
use TestInlineSetup;

use Test::More;

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

use File::Path;
END {
    rmtree('_Inline');
}

__END__

__Foo__

foo-sub add {
    foo-return $_[0] + $_[1];
}
