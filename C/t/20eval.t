BEGIN {
  if (exists $ENV{PERL_INSTALL_ROOT}) {
    warn "\nIgnoring \$ENV{PERL_INSTALL_ROOT} in $0\n";
    delete $ENV{PERL_INSTALL_ROOT};
  }
};

use strict;
use warnings;

print "1..5\n";



eval {
 require Inline;
 Inline->import(Config =>
                DIRECTORY => '_Inline_test');
 Inline->import (C =><<'EOC');

 int foo() {
   return 42;
 }

EOC
};

if($@) {
  *foo =\&bar;
}

my $x = foo();

if($x == 42) {print "ok 1\n"}
else {
  warn "\n\$x: $x\n";
  print "not ok 1\n";
}

$x = bar();

if($x == 43) {print "ok 2\n"}
else {
  warn "\n\$x: $x\n";
  print "not ok 2\n";
}

eval {
 require Inline;
 Inline->import(C => Config =>
                DIRECTORY => '_Inline_test',
                #BUILD_NOISY => 1,
                CC => 'missing_compiler');
 Inline->import (C =><<'EOC');

 int fu() {
   return 44;
 }

EOC
};

if($@) {
  *fu =\&fubar;
}

$x = fu();

if($x == 45) {print "ok 3\n"}
else {
  warn "\n\$x: $x\n";
  print "not ok 3\n";
}

$x = fubar();

if($x == 45) {print "ok 4\n"}
else {
  warn "\n\$x: $x\n";
  print "not ok 4\n";
}

if($@ =~ /missing_compiler/) {print "ok 5\n"}
else {
  warn "\n\$\@ not as expected\n";
  print "not ok 5\n";
}

sub bar {
  return 43;
}

sub fubar {
  return 45;
}

