# Checks that Inline's bind function still works when $_ is readonly. (Bug #55607)
# Thanks Marty O'Brien.

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

print "1..1\n";

# The following construct not allowed under
# strictures (refs). Hence strictures for
# refs have been turned off.
{
no strict ('refs');
  for ('function') {
    $_->();
  }
}

if(foo(15) == 30) {print "ok 1\n"}
else {
  warn "Expected 30, got ", foo(15), "\n";
  print "not ok 1\n";
}

sub function {
  use Inline C => Config =>
    DIRECTORY => '_Inline_test',
    USING => 'ParseRegExp';

    Inline->bind(C => <<'__CODE__');
    int foo(SV * x) {
      return (int)SvIV(x) * 2;
    }
__CODE__
}
