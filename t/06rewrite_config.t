BEGIN {
  if($] < 5.007) {
    print "1..1\n";
    warn "Skipped for perl 5.6.x\n";
    print "ok 1\n";
    exit(0);
  }
};

use warnings;
use strict;
use Test::More tests => 2;

use Test::Warn;

# Suppress "Set up gcc environment ..." warning.
# (Affects ActivePerl only.)
$ENV{ACTIVEPERL_CONFIG_SILENT} = 1;

my $w = 'config file removal successful';

warnings_like {require_rewrite()} [qr/$w/], 'warn_test';

sub require_rewrite {
    require './t/06rewrite_config.p';
}
