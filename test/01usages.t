use strict; use warnings;
use File::Basename;
use lib dirname(__FILE__);
use TestInlineSetup;

use Test::More;

use Inline Config => DIRECTORY => '_Inline_01usages';

BEGIN {
    # plan(tests => 9,
    plan(tests => 7,
         todo => [],
         onfail => sub {},
    );
}

my $t; BEGIN { $t = -d 't' ? 't' : 'test' }

# test 1
# Make sure that the syntax for reading external files works.
use Inline Foo => File::Spec->catfile(File::Spec->curdir(),$t,'file');
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

# XXX Not working with `prove -lv t` yet

# # test 8
# # Make sure 'with' works
# {
#   package FakeMod;
#   $INC{__PACKAGE__.'.pm'} = 1;
#   sub Inline { return unless $_[1] eq 'Foo'; { PATTERN=>'qunx-' } }
# }
# Inline->import(with => 'FakeMod');
# Inline->bind(Foo => 'qunx-sub subtract2 { qunx-return $_[0] qunx-- $_[1]; }');
# ok(subtract2(3, 7) == -4);
# 
# { package NoWith; $INC{__PACKAGE__.'.pm'} = 1; sub Inline { } }
# Inline->import(with => 'NoWith');
# eval { Inline->bind(NoWith => 'whatever'); };
# ok($@);

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
