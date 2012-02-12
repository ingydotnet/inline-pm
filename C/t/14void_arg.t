BEGIN {
  if (exists $ENV{PERL_INSTALL_ROOT}) {
    warn "\nIgnoring \$ENV{PERL_INSTALL_ROOT} in $0\n";
    delete $ENV{PERL_INSTALL_ROOT};
  }
  mkdir('_Inline_test', 0777) unless -e '_Inline_test';
};
use File::Spec;
use lib (File::Spec->catdir(File::Spec->updir(),'blib','lib'), File::Spec->catdir(File::Spec->curdir(),'blib','lib'));
use strict;
use diagnostics;

print "1..12\n";

use Inline C => Config =>
    FORCE_BUILD => 1,
    DIRECTORY => '_Inline_test',
    USING => 'ParseRegExp';

use Inline C => <<'EOC';

void foo1(void) {
     printf("Hello from foo1\n");
}

int foo2(void) {
    return 42;
}

SV * foo3(void) {
     return newSVnv(42.0);
}

void foo4() {
     printf("Hello from foo4\n");
}

int foo5() {
    return 42;
}

SV * foo6() {
     return newSVnv(42.0);
}

void foo7( void ) {
     printf("Hello from foo7\n");
}

int foo8(  void  ) {
    return 43;
}

SV * foo9(   void ) {
     return newSVnv(43.0);
}

void foo10
    ( void ) {
     printf("Hello from foo10\n");
}

int foo11  (  void  )
  {
    return 44;
  }

SV * foo12
 (   void )
  {
     return newSVnv(44.0);
}

EOC

eval {foo1();};
if($@) {
  warn "\$\@: $@";
  print "not ok 1\n";
}
else { print "ok 1\n"}

if(42 == foo2()) {print "ok 2\n"}
else {print "not ok 2\n"}

if(42 == foo3()) {print "ok 3\n"}
else {print "not ok 3\n"}

eval {foo4();};
if($@) {
  warn "\$\@: $@";
  print "not ok 4\n";
}
else { print "ok 4\n"}

if(42 == foo5()) {print "ok 5\n"}
else {print "not ok 5\n"}

if(42 == foo6()) {print "ok 6\n"}
else {print "not ok 6\n"}

eval {foo7();};
if($@) {
  warn "\$\@: $@";
  print "not ok 7\n";
}
else { print "ok 7\n"}

if(43 == foo8()) {print "ok 8\n"}
else {print "not ok 8\n"}

if(43 == foo9()) {print "ok 9\n"}
else {print "not ok 9\n"}

eval {foo10();};
if($@) {
  warn "\$\@: $@";
  print "not ok 10\n";
}
else { print "ok 10\n"}

if(44 == foo11()) {print "ok 11\n"}
else {print "not ok 11\n"}

if(44 == foo12()) {print "ok 12\n"}
else {print "not ok 12\n"}
