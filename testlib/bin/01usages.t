use Test; 
plan( tests => 1);

# test 5
# Make sure language name aliases work ('foo' instead of 'Foo')

ok(test5('test5'));

use Inline foo => <<'END_OF_FOO';
foo-sub test5 {
    foo-return $_[0] foo-eq 'test5';
}
END_OF_FOO
