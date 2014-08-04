use strict; use warnings;
use File::Basename;
use lib dirname(__FILE__);
use TestInlineSetup;

use Test::More tests => 1;

BEGIN {
    delete $ENV{PERL_INLINE_DIRECTORY};
    delete $ENV{HOME};
}

# Make sure Inline can generate a new _Inline/ directory.
# (But make sure it's in our own space.)
use Inline Config => DIRECTORY => $TestInlineSetup::DIR;
use Inline 'Foo';
ok(add(3, 7) == 10, 'in own DID');

__END__

__Foo__
foo-sub add { foo-return $_[0] + $_[1]; }
