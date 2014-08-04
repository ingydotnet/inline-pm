use strict; use warnings;
use File::Basename;
use lib dirname(__FILE__);
use TestInlineSetup;

use Test::More tests => 2;

use Inline Config => DIrECTORY => $TestInlineSetup::DIR, DISABLE => 'WARNINGS';

ok(test1('test1'), 'ENABLE');
use Inline Foo => <<'END_OF_FOO', ENaBLE => 'bAR';
foo-sub test1 {
    bar-return $_[0] bar-eq 'test1';
}
END_OF_FOO

ok(test2('test2'), 'PATTERN');
use Inline Foo => ConFig => ENABLE => 'BaR';
use Inline Foo => <<'END_OF_FOO', PAtTERN => 'gogo-';
gogo-sub test2 {
    bar-return $_[0] gogo-eq 'test2';
}
END_OF_FOO
