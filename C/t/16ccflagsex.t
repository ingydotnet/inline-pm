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
use Config;

print "1..1\n";

use Inline C => Config =>
    #BUILD_NOISY => 1,
    FORCE_BUILD => 1,
    CCFLAGSEX => "-DEXTRA_DEFINE=1234",
    DIRECTORY => '_Inline_test';

use Inline C => <<'EOC';

int foo() {
    return EXTRA_DEFINE;
}

EOC

my $def = foo();

if($def == 1234) {
  print "ok 1\n";
}
else {
  warn "\n Expected: 1234\n Got: $def\n";
  print "not ok 1\n";
}
