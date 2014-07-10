use File::Spec;
use lib (File::Spec->catdir(File::Spec->curdir(),'blib','lib'), File::Spec->curdir());
use strict;
use Test;
use diagnostics;
use Inline Config => DIRECTORY => '_Inline_test';

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


