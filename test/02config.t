use strict; use warnings;
use File::Basename;
use lib dirname(__FILE__);
use TestInlineSetup;

use Test::More;

use Inline Config => DIRECTORY => '_Inline_02config';

BEGIN {
    plan(tests => 2,
         todo => [],
         onfail => sub {},
    );
}

# test 1
# Make sure ENABLE works
ok(test1('test1'));
use Inline Foo => <<'END_OF_FOO', ENABLE => 'BAR';
foo-sub test1 {
    bar-return $_[0] bar-eq 'test1';
}
END_OF_FOO

# test 2
# Make sure PATTERN works
ok(test2('test2'));
use Inline Foo => Config => ENABLE => 'BAR';
use Inline Foo => <<'END_OF_FOO', PATTERN => 'gogo-';
gogo-sub test2 {
    bar-return $_[0] gogo-eq 'test2';
}
END_OF_FOO
