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
use Cwd;

BEGIN {
  my $cwd = Cwd::getcwd();
  my $incdir1 = $cwd . '/t/foo/';
  my $incdir2 = $cwd . '/t/bar/';
  $main::includes = "-I$incdir1  -I$incdir2";
};


use Inline C => Config =>
 INC => $main::includes,
 DIRECTORY => '_Inline_test';

use Inline C => <<'EOC';

#include <find_me_in_foo.h>
#include <find_me_in_bar.h>

SV * foo() {
  return newSViv(-42);
}

EOC

print "1..1\n";

my $f = foo();
if($f == -42) {print "ok 1\n"}
else {
  warn "\n\$f: $f\n";
  print "not ok 1\n";
}



