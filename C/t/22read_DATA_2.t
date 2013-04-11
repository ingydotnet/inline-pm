# This file checks that a bug in Inline::read_DATA() has been fixed.
# The bug existed up to and including Inline-0.52.

BEGIN {
  if (exists $ENV{PERL_INSTALL_ROOT}) {
    warn "\nIgnoring \$ENV{PERL_INSTALL_ROOT} in $0\n";
    delete $ENV{PERL_INSTALL_ROOT};
  }
};
use File::Spec;
use lib (File::Spec->catdir(File::Spec->updir(),'blib','lib'), File::Spec->catdir(File::Spec->curdir(),'blib','lib'));
use strict;
use warnings;

use Inline C => 'DATA';

print "1..1\n";

my $foo = foo1() + foo2();

if($foo == 15) {print "ok 1\n"}
else {
  warn "\$foo: $foo\n";
  print "not ok 1\n";
}


__DATA__
__C__


#ifndef __Python__
#define __Python__ 8
#endif

int foo1() {
  int ret;
  if(__Python__ == 8) {
    ret = __Python__
          - 1;
  }
  else ret = 7;
  return ret;
}

int foo2() {
  if(__Python__ == 8)
    return __Python__;
  else return 8;
}

