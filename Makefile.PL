use ExtUtils::MakeMaker;

my $twv = $] > 5.013 ? 0.23 : 0.21;

my $prereq_pm = $] > 5.007 ?
                             {
                              Data::Dumper => 2.09,
                              Digest::MD5 => 2.09,
	                        Parse::RecDescent => 1.80,
                              File::Spec => 0.8,
                              Test::Warn => $twv,
                             }

                           :
                             {
                              Data::Dumper => 2.09,
                              Digest::MD5 => 2.09,
	                        Parse::RecDescent => 1.80,
                              File::Spec => 0.8,
                             };

WriteMakefile(
    NAME => 'Inline',
    VERSION_FROM => 'Inline.pm',
    PREREQ_PM => $prereq_pm,
    clean => {FILES => '_Inline_test _Inline .Inline'},
);

if ($^O =~ /Win32/i) {
    print "Fixing Makefile for MSWin32\n";
    open MAKEFILE, "< Makefile"
      or die "Can't open Makefile for reading";
    my @lines = <MAKEFILE>;
    close MAKEFILE;
    open MAKEFILE, "> Makefile"
      or die "Can't open Makefile for writing";
    for (@lines) {
        print MAKEFILE unless /^\s*((\@\[)|(\]))\s*$/;
    }
    close MAKEFILE;
}
