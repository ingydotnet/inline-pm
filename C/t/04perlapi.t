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

BEGIN {
    plan(tests => 1,
	 todo => [],
	 onfail => sub {},
	);
}

use Inline 'C';

$main::myvar = $main::myvar = "myvalue";

# test 1
ok(lookup('main::myvar') eq "myvalue");

__END__

__C__

SV* lookup(char* var) {
    return perl_get_sv(var, 0);
}
