use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'Inline',
    VERSION => '0.44-RELEASE-CANDIDATE-2',
    # VERSION_FROM => 'Inline.pm',
    PREREQ_PM => {
        Data::Dumper => 2.09,
        Digest::MD5 => 2.09,
	Parse::RecDescent => 1.78,
    },
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
