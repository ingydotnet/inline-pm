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
    USING => 'ParseRegExp',
    DIRECTORY => '_Inline_test',
    PREFIX => 'MY_PRE_';

use Inline C => << 'EOC';

int bar() {
    return 42;
}

int MY_PRE_foo(void) {
    int x = bar();
    return x;
}

EOC

if(42 == foo()) {print "ok 1\n"}
else {print "not ok 1\n"}
