BEGIN {
  if (exists $ENV{PERL_INSTALL_ROOT}) {
    warn "\nIgnoring \$ENV{PERL_INSTALL_ROOT} in $0\n";
    delete $ENV{PERL_INSTALL_ROOT};
  }
};
use File::Spec;
use lib (File::Spec->catdir(File::Spec->updir(),'blib','lib'), File::Spec->catdir(File::Spec->curdir(),'blib','lib'));
use strict;
use Test;
use diagnostics;
use Inline Config => DIRECTORY => '_Inline_test';

plan(tests => 1,
     todo => [],
     onfail => sub {},
    );

use Inline C => DATA =>
           TYPEMAPS => File::Spec->catfile(File::Spec->curdir(),'t','typemap');

# test 1
ok(int((add_em_up(1.2, 3.4) + 0.001) * 10) == 46);

__END__

__C__

float add_em_up(float x, float y) {
    return x + y;
}
