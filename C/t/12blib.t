use warnings;
use strict;

# This just checks that we're using blib (and hence the Inline.pm that's in blib)
# when writing the configuration file while running 'make test'.

BEGIN {
  mkdir '_Inline_blib_test' unless -d '_Inline_blib_test';
  open WR, '>', '_Inline_blib_test/blib_test' or warn "Couldn't create _Inline_blib_test/blib_test: $!";
  close WR or warn "Couldn't close _Inline_blib_test/blib_test after creating: $!";
};

use Inline C => Config =>
    FORCE_BUILD => 1,
    DIRECTORY => '_Inline_blib_test';

use Inline C => <<'EOC';
int foo(int x) {
     return x * 3;
}

EOC

print "1..2\n";

open RD, '<', '_Inline_blib_test/blib_test' or warn "Can't open blib_test for reading: $!";
my @lines = <RD>;
close RD or warn "Can't close blib_test after reading: $!";

my $ret = foo(17);
if($ret == 51) {print "ok 1\n"}
else {
  warn "Expected 51, got $ret\n";
  print "not ok 1\n";
}

my $ok = 1;

unless(@lines == 1) {
  warn "Expected one line written to file, got ", scalar(@lines), "\n";
  $ok = 0;
}


if($ENV{HARNESS_ACTIVE}) {
  unless ($lines[0] eq "-Mblib -MInline=_CONFIG_\n") {
    $ok = 0;
    warn "Running under Test::Harness, got: *$lines[0]*";
  }
}
else {
  warn "Not running under Test::Harness\n";
  unless ($lines[0] eq "-MInline=_CONFIG_\n") {
    $ok = 0;
    warn "Test::Harness inactive, got: *$lines[0]*";
  }
}



if($ok) {print "ok 2\n"}
else {print "not ok 2\n"}

warn "Couldn't delete configuration file\n" if !unlink "_Inline_blib_test/$Inline::configuration_file";
warn "Couldn't delete blib_test file\n" if !unlink '_Inline_blib_test/blib_test';

