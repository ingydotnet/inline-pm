use strict; use warnings;
use File::Basename;
use lib dirname(__FILE__);
use TestInlineSetup;

use Test::More;

use Inline Config => DIRECTORY => '_Inline_05files';

BEGIN {
    eval "require Inline::Files";
    if ($@) {
        warn "Skipping - couldn't load the Inline::Files module\n";
        print "1..1\nok 1\n";
        exit 0;
    }
}

use Inline::Files;

BEGIN {
    plan(tests => 1,
         todo => [],
         onfail => sub {},
    );
}

# test 1
# Make sure that Inline::Files support works
use Inline Foo => 'BELOW';
ok(test1('test1'));

__FOO__

foo-sub test1 {
    foo-return $_[0] foo-eq 'test1';
}
