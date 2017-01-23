use strict; use warnings; use utf8;
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use lib -e 't' ? 't' : 'test';
use TestInlineSetup;

use Test::More tests => 1;

use Inline Config => DIrECTORY => $TestInlineSetup::DIR, DISABLE => 'WARNINGS';

ok(test2('𝘛𝘩𝘪𝘴 𝘪𝘴 𝘜𝘯𝘪𝘤𝘰𝘥𝘦 𝘵𝘦𝘹𝘵.'), 'UTF-8');
use Inline Foo => ConFig => ENABLE => 'BaR';
use Inline Foo => <<'END_OF_FOO', PAtTERN => 'gogo-';
use utf8;

gogo-sub test2 {
    bar-return $_[0] gogo-eq '𝘛𝘩𝘪𝘴 𝘪𝘴 𝘜𝘯𝘪𝘤𝘰𝘥𝘦 𝘵𝘦𝘹𝘵.';
}
END_OF_FOO
