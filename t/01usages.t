use File::Spec;
use lib (File::Spec->catdir(File::Spec->curdir(),'blib','lib'), File::Spec->curdir());
use strict;
use Test;
use diagnostics;
use Inline Config => DIRECTORY => '_Inline_test';

BEGIN {
    plan(tests => 7,
	 todo => [],
	 onfail => sub {},
	);
}

use Inline Config => DIRECTORY => '_Inline_test';

# test 1
# Make sure that the syntax for reading external files works.
use Inline Foo => File::Spec->catfile(File::Spec->curdir(),'t','file');
ok(test1('test1'));

# test 2 & 3
# Make sure that data files work
use Inline Foo => 'DATA';
ok(test2('test2'));
use Inline 'Foo';
ok(not test3('test3'));

# test 4
# Make sure string form works
ok(test4('test4'));
use Inline Foo => <<'END_OF_FOO';
foo-sub test4 {
    foo-return $_[0] foo-eq 'test4';
}
END_OF_FOO

# test 5
# Make sure language name aliases work ('foo' instead of 'Foo')
ok(test5('test5'));
use Inline foo => <<'END_OF_FOO';
foo-sub test5 {
    foo-return $_[0] foo-eq 'test5';
}
END_OF_FOO

# test 6
# Make sure Inline->init works
eval <<'END';
use Inline Foo => 'DATA';
Inline->init;
ok(add(3, 7) == 10);

END

print "$@\nnot ok 1\n" if $@;

# test 7
# Make sure bind works
eval <<'END';
Inline->bind(Foo => <<'EOFOO');
foo-sub subtract {
    foo-return $_[0] foo-- $_[1];
}
EOFOO
ok(subtract(3, 7) == -4);

END

print "$@\nnot ok 2\n" if $@;

__END__

__Foo__
# Inline Foo file

foo-sub test2 {
    foo-return $_[0] foo-eq 'test2';
}

__Foo__

foo-sub test3 {
    foo-return $_[0] foo-eq 'yrlnry';
}

__Foo__

foo-sub add {
    foo-return $_[0] foo-+ $_[1];
}
