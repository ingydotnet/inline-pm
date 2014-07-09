# Tests handling of the "void" arg with Parse::RecDescent parser.
# Tests 4 onwards are not expected to pass - so we make them TODO.

BEGIN {
  if (exists $ENV{PERL_INSTALL_ROOT}) {
    warn "\nIgnoring \$ENV{PERL_INSTALL_ROOT} in $0\n";
    delete $ENV{PERL_INSTALL_ROOT};
  }
  mkdir('_Inline_test', 0777) unless -e '_Inline_test';
};
use strict;
use warnings;
use diagnostics;
use Test::More;
use AutoLoader 'AUTOLOAD';

use Inline C => Config =>
    FORCE_BUILD => 1,
    DIRECTORY => '_Inline_test',
    USING => 'ParseRecDescent';

my $c_text = <<'EOC';

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
Inline->bind(C => $c_text);

sub run_tests {
  for my $f (qw(foo4)) { eval "$f();"; is($@, '', $f); }
  for my $f (qw(foo5 foo6)) { no strict 'refs'; is(&$f, 42, $f); }
  for my $f (qw(foo1 foo2 foo3 foo7 foo8 foo9 foo10 foo11 foo12)) {
      TODO: {
          local $TODO = "Not expected to succeed with ParseRecDescent parser";
          eval "$f();"; is($@, '', $f);
      };
 }
}

run_tests();
done_testing;
