use strict; use warnings;
use File::Basename;
use lib dirname(__FILE__);
use TestInlineSetup;

use Test::More;

use Inline Config => DIRECTORY => '_Inline_01usages';

my $t; BEGIN { $t = -d 't' ? 't' : 'test' }

use Inline Foo => File::Spec->catfile(File::Spec->curdir(),$t,'file');
ok(test1('test1'), 'read external file');

use Inline Foo => 'DATA';
ok(test2('test2'), 'DATA handle');
use Inline 'Foo';
ok(!test3('test3'), 'unspecified = DATA handle');

ok(test4('test4'), 'given as string');
use Inline Foo => 'foo-sub test4 { foo-return $_[0] foo-eq "test4"; }';

ok(test5('test5'), 'lang alias');
use Inline foo => 'foo-sub test5 { foo-return $_[0] foo-eq "test5"; }';

eval <<'END';
use Inline Foo => 'DATA';
Inline->init;
ok(add(3, 7) == 10, 'Inline->init actual');
END
is($@, '', 'init');

Inline->bind(Foo => 'foo-sub subtract { foo-return $_[0] foo-- $_[1]; }');
is(subtract(3, 7), -4, 'bind');

{
  package FakeMod;
  $INC{__PACKAGE__.'.pm'} = 1;
  sub Inline { return unless $_[1] eq 'Foo'; { PATTERN=>'qunx-' } }
}
Inline->import(with => 'FakeMod');
Inline->bind(Foo => 'qunx-sub subtract2 { qunx-return $_[0] qunx-- $_[1]; }');
is(subtract2(3, 7), -4, 'with works');

{ package NoWith; $INC{__PACKAGE__.'.pm'} = 1; sub Inline { } }
Inline->import(with => 'NoWith');
eval { Inline->bind(NoWith => 'whatever'); };
isnt($@, '', 'check "with" croaks if no info returned');

done_testing;

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
