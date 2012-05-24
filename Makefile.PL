use ExtUtils::MakeMaker;

my $md5_check = 1; # Assume that if $] < 5.008001, then Digest::MD5 is already installed.

if($] < 5.008001) {
  eval{require Digest::MD5;};
  if($@) {
    warn "\$\@: $@\n";
    warn "  This is perl version $]\n";
    $md5_check = 0; # Above assumption was wrong.
  }
}

unless($md5_check) {
  warn <<'  MD5';
  A functional version of the pre-requisite Digest::MD5
  seems to be missing.
  Digest-MD5-2.41 and later will not build on this old
  build of perl.
  CPAN.pm will currently attempt (and fail) to build and
  install the *latest* version of Digest::MD5.
  Therefore you must either:
   a) install Digest-MD5-2.40 (or earlier, back to 2.09) or;
   b) apply either the patch at
      https://rt.cpan.org/Ticket/Attachment/1038207/542063/d0
      or the patch at
      https://rt.cpan.org/Ticket/Attachment/983638/512188/Digest-MD5-2.51-v5.6.patch
      to the latest Digest::MD5 source and then build
      and install that patched version.

  It is hoped that, eventually, Digest::MD5 will be once
  again rendered compatible with this version of perl. If
  and when that happens, please let the current maintainer
  of Inline know, so that this warning can be removed.

  MD5

  exit 0;
}

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
