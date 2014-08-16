BEGIN {
  if($] < 5.007) {
    print "1..1\n";
    warn "Skipped for perl 5.6.x\n";
    print "ok 1\n";
    exit(0);
  }
};

use warnings; use strict;
use lib -e 't' ? 't' : 'test';
use Test::More tests => 2;

use Test::Warn;

use TestInlineSetup;
use Inline Config => DIRECTORY => $TestInlineSetup::DIR;
eval q{use Inline 'Bogus' => 'code';};

# Suppress "Set up gcc environment ..." warning.
# (Affects ActivePerl only.)
$ENV{ACTIVEPERL_CONFIG_SILENT} = 1;

my $w = 'config file removal successful';

warnings_like {require_rewrite()} [qr/$w/], 'warn_test';

sub require_rewrite {
    my $t = -d 't' ? 't' : 'test';
    require "./$t/06rewrite_config.p";
}
