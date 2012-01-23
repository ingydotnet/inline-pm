#!perl -T

BEGIN {
  if($] < 5.007) {
    print "1..1\n";
    warn "Skipped for perl 5.6.x\n";
    print "ok 1\n";
    exit(0);
  }
};

BEGIN {
  if (exists $ENV{PERL_INSTALL_ROOT}) {
    warn "\nIgnoring \$ENV{PERL_INSTALL_ROOT} in $0\n";
    delete $ENV{PERL_INSTALL_ROOT};
  }
};

use warnings;
use strict;
use Test::More tests => 10;

use Test::Warn;

# Suppress "Set up gcc environment ..." warning.
# (Affects ActivePerl only.)
$ENV{ACTIVEPERL_CONFIG_SILENT} = 1;

my $w1 = 'Blindly untainting tainted fields in %ENV';
my $w2 = 'Blindly untainting Inline configuration file information';
my $w3 = 'Blindly untainting tainted fields in Inline object';

warnings_like {require_taint_1()} [qr/$w1/, qr/$w2/, qr/$w1/, qr/$w3/], 'warn_test 1';
warnings_like {require_taint_2()} [qr/$w1/, qr/$w2/, qr/$w1/, qr/$w3/], 'warn_test 2';
warnings_like {require_taint_3()} [qr/$w1/, qr/$w2/, qr/$w1/, qr/$w3/, qr/$w1/, qr/$w2/, qr/$w1/, qr/$w3/], 'warn_test 3';

sub require_taint_1 {
    require './t/08taint_1.p';
}

sub require_taint_2 {
    require './t/08taint_2.p';
}

sub require_taint_3 {
    require './t/08taint_3.p';
}
