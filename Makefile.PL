use inc::Module::Install;

name('Inline');
author('Ingy döt Net <ingy@cpan.org>');
abstract('Write Perl subroutines in other programming languages');
license('perl');
version_from('lib/Kwiki.pm');

requires(qw(
    perl 5.5.3
    Data::Dumper 2.09
    Digest::MD5 2.09
    File::Spec 0.8
));

check_nmake();

&WriteAll();

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
