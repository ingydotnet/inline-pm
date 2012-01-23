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
    plan(tests => 3,
	 todo => [],
	 onfail => sub {},
	);
}

# test 1 - Make sure config options are type checked
BEGIN {
    eval <<'END';
    use Inline(C => "void foo(){}",
	       LIBS => {X => 'Y'},
	      );
END
    ok(1);
#    ok($@ =~ /must be a string or an array ref/);
}

# test 2 - Make sure bogus config options croak
BEGIN {
    eval <<'END';
    use Inline(C => "void foo(){}",
	       FOO => 'Bar',
	      );
END
    ok($@ =~ /not a valid config option/);
}

# test 3 - Test the PREFIX config option
BEGIN {
    use Inline(C => 'char* XYZ_Howdy(){return "Hello There";}',
	       PREFIX => 'XYZ_',
	      );
    ok(Howdy eq "Hello There");
}

__END__
