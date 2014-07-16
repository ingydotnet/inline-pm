BEGIN {
  if($] < 5.007) {
    print "1..1\n";
    warn "Skipped for perl 5.6.x\n";
    print "ok 1\n";
    exit(0);
  }
};

use strict; use warnings;
use File::Basename;
use lib dirname(__FILE__);
use TestInlineSetup;

use Test::More tests => 2;

use Test::Warn;

# Suppress "Set up gcc environment ..." warning.
# (Affects ActivePerl only.)
$ENV{ACTIVEPERL_CONFIG_SILENT} = 1;

my $w = 'config file removed';

warnings_like {require_rewrite()} [qr/$w/], 'warn_test';

ok($@, '"Inline Bogus" test');

sub require_rewrite {
    my $t = -d 't' ? 't' : 'test';
    eval {require "./$t/07rewrite2_config.p";};
}
