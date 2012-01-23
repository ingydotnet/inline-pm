BEGIN {
  if (exists $ENV{PERL_INSTALL_ROOT}) {
    warn "\nIgnoring \$ENV{PERL_INSTALL_ROOT} in $0\n";
    delete $ENV{PERL_INSTALL_ROOT};
  }
};
use File::Spec;
use lib (File::Spec->catdir(File::Spec->updir(),'blib','lib'), File::Spec->catdir(File::Spec->curdir(),'blib','lib'));
use strict;
use diagnostics;

BEGIN { warn "\nThis test could take a couple of minutes to run\n"; };

print "1..1\n";

#use Inline Config =>
#    DIRECTORY => '_Inline_test',
#    _TESTING => 1;

########## main:foo_ ########
use Inline C => Config =>
   DIRECTORY => '_Inline_test',
   FORCE_BUILD => 1,
   _TESTING => 1,
   USING => 'ParseRegExp';

use Inline C => <<'EOC';

int foo_() {
     return -1;
}

EOC

########## main:_foo_ ########
# Use same Config options as for main::foo()
use Inline C => <<'EOC';

int _foo_() {
     return -3;
}

EOC

########## main:_foo ########
use Inline C => Config =>
   DIRECTORY => '_Inline_test',
   FORCE_BUILD => 1,
   _TESTING => 1,
   USING => 'ParseRecDescent';

use Inline C => <<'EOC';

int _foo() {
     return 2;
}

EOC

########## main:foo ########
use Inline C => Config =>
   DIRECTORY => '_Inline_test',
   FORCE_BUILD => 1,
   _TESTING => 1,
   USING => 'ParseRegExp';

use Inline C => <<'EOC';

int foo() {
     return 1;
}

EOC

########## main:bar ########
# No 'USING' value specified here - will use default (ParseRecDescent).
use Inline C => Config =>
   DIRECTORY => '_Inline_test',
   FORCE_BUILD => 1,
   _TESTING => 1;

use Inline C => <<'EOC';

int bar() {
     return 2;
}

EOC

########## main:baz ########
use Inline C => Config =>
   DIRECTORY => '_Inline_test',
   FORCE_BUILD => 1,
   _TESTING => 1,
   USING => 'ParseRecDescent';

use Inline C => <<'EOC';

int baz() {
     return 3;
}

EOC

########## main:foobar ########
# No 'USING' value specified here - will use default (ParseRecDescent).
use Inline C => Config =>
   DIRECTORY => '_Inline_test',
   FORCE_BUILD => 1,
   _TESTING => 1;

use Inline C => <<'EOC';

int foobar() {
     return 4;
}

EOC

########## main:foobarbaz ########
# Use same config options as for main::foobar().
use Inline C => <<'EOC';

int foobarbaz() {
     return 5;
}

EOC

########## FOO::foo ########
package FOO;

use Inline C => Config =>
   DIRECTORY => '_Inline_test',
   FORCE_BUILD => 1,
   _TESTING => 1,
   USING => 'ParseRecDescent';

use Inline C => <<'EOC';

int foo() {
     return 6;
}

EOC

########## BAR::bar ########
package BAR;

use Inline C => Config =>
   DIRECTORY => '_Inline_test',
   FORCE_BUILD => 1,
   _TESTING => 1;

use Inline C => <<'EOC';

int bar() {
     return 7;
}

EOC

########## BAZ::baz ########
package BAZ;

use Inline C => Config =>
   DIRECTORY => '_Inline_test',
   FORCE_BUILD => 1,
   _TESTING => 1,
   USING => 'ParseRegExp';

use Inline C => <<'EOC';

int baz() {
     return 8;
}

EOC

########## BAZ::baz_ ########
# Use same Config options as for BAZ::bar()

use Inline C => <<'EOC';

int baz_() {
     return -2;
}

EOC

########################################

########################################

my $ok;
my $prod = -483840;
my $res = main::foo_() * main::_foo() * main::_foo_() * main::foo() * main::bar() * main::baz() *
          main::foobar() * main::foobarbaz() * FOO::foo() * BAR::bar() * BAZ::baz() * BAZ::baz_();

if($res == $prod) {$ok .= 'a'}
else {warn "1a: Got $res\nExpected $prod\n"}

open(RD, '<', '_Inline_test/parser_id') or warn $!;
my @p = <RD>;

my $lines = 16;

if(scalar(@p) == $lines) {$ok .= 'b'}
else {warn "1b: Got ", scalar(@p), "\nExpected $lines\n"}

if($p[0] eq "Inline::C::ParseRegExp::get_parser called\n") {$ok .= 'c'}
else {warn "1c: Got $p[0]\n"}

if($p[1] eq "Inline::C::ParseRegExp::get_parser called\n") {$ok .= 'd'}
else {warn "1d: Got $p[1]\n"}

if($p[2] eq "Inline::C::ParseRecDescent::get_parser called\n") {$ok .= 'e'}
else {warn "1e: Got $p[2]\n"}

if($p[3] eq "Inline::C::ParseRegExp::get_parser called\n") {$ok .= 'f'}
else {warn "1f: Got $p[3]\n"}

if($p[4] eq "Inline::C::get_parser called\n") {$ok .= 'g'}
else {warn "1g: Got $p[4]\n"}

if($p[5] eq "Inline::C::ParseRecDescent::get_parser called\n") {$ok .= 'h'}
else {warn "1h: Got $p[5]\n"}

if($p[6] eq "Inline::C::ParseRecDescent::get_parser called\n") {$ok .= 'i'}
else {warn "1i: Got $p[6]\n"}

if($p[7] eq "Inline::C::get_parser called\n") {$ok .= 'j'}
else {warn "1j: Got $p[7]\n"}

if($p[8] eq "Inline::C::ParseRecDescent::get_parser called\n") {$ok .= 'k'}
else {warn "1k: Got $p[8]\n"}

if($p[9] eq "Inline::C::get_parser called\n") {$ok .= 'l'}
else {warn "1l: Got $p[9]\n"}

if($p[10] eq "Inline::C::ParseRecDescent::get_parser called\n") {$ok .= 'm'}
else {warn "1m: Got $p[10]\n"}

if($p[11] eq "Inline::C::ParseRecDescent::get_parser called\n") {$ok .= 'n'}
else {warn "1n: Got $p[11]\n"}

if($p[12] eq "Inline::C::get_parser called\n") {$ok .= 'o'}
else {warn "1o: Got $p[12]\n"}

if($p[13] eq "Inline::C::ParseRecDescent::get_parser called\n") {$ok .= 'p'}
else {warn "1p: Got $p[13]\n"}

if($p[14] eq "Inline::C::ParseRegExp::get_parser called\n") {$ok .= 'q'}
else {warn "1q: Got $p[14]\n"}

if($p[15] eq "Inline::C::ParseRegExp::get_parser called\n") {$ok .= 'r'}
else {warn "1r: Got $p[15]\n"}

close(RD) or warn $!;

if($ok eq 'abcdefghijklmnopqr') {print "ok 1\n"}
else {
  warn "\$ok: $ok\n";
  print "not ok 1\n";
}

Inline::C::_testing_cleanup();
