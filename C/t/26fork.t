use warnings;
use strict;
use Config;
use Test::More;
use File::Path;

BEGIN {
  if (exists $ENV{PERL_INSTALL_ROOT}) {
  warn "\nIgnoring \$ENV{PERL_INSTALL_ROOT} in $0\n";
  delete $ENV{PERL_INSTALL_ROOT};
  }
  rmtree('_Inline_test/lib', 0, 0);
}

if($^O =~ /MSWin32/i && $Config{useithreads} ne 'define') {
  plan skip_all => 'fork() not implemented';
  exit 0;
}

# Suppress "Set up gcc environment ..." warning.
# (Affects ActivePerl only.)
$ENV{ACTIVEPERL_CONFIG_SILENT} = 1;

mkdir '_Inline_test' unless -d '_Inline_test';

use Inline Config => DIRECTORY => '_Inline_test';

my $pid = fork;
eval { Inline->bind(C => 'int add(int x, int y) { return x + y; }'); };
exit 0 unless $pid;

wait;
is($?, 0, 'child exited status 0');
is($@, '', 'bind was successful');
my $x = eval { add(7,3) };
is ($@, '', 'bound func no die()');
is($x, 10, 'bound func gave right result');

done_testing;


