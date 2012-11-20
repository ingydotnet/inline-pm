BEGIN {
  if (exists $ENV{PERL_INSTALL_ROOT}) {
    warn "\nIgnoring \$ENV{PERL_INSTALL_ROOT} in $0\n";
    delete $ENV{PERL_INSTALL_ROOT};
  }
};

use strict;
use warnings;
use Cwd;

require Inline::C;

my $t = 10;
print "1..$t\n";

my $ok = 1;
my $expected;

my @t1 =
 (
  '-I/foo -I/bar',
  '  -I/foo  -I/bar      -I/baz  ',
  ' -I/foo -I" - I/? ',
  '   -I/for-Ian -I/for-Ingy    -I/for-some-Idiocy  ',
  'some_crap -I-I-I -I/for-Ian -I/for-Ingy    -I/for-some-Idiocy  -I/foo -I/bar ',
  '	-I/foo	-I/bar	-I/fubar',
 );

for my $e1(@t1) {
  $expected = $e1;
  my $got = Inline::C::quote_space($e1);
  unless($got eq $expected) {
    $ok = 0;
    warn "\nGot:      **$got**\n",
           "Expected: **$expected**\n";
  }
}

if($ok) {print "ok 1\n"}
else {print "not ok 1\n"}


my @t2 =
 (
  '-I/foo and fu -I/bar',
  '  -I/foo  -I/bar   and  baa     -I/baz  ',
  ' -I/foo and fu -I" - I/? ',
  '   -I/for-Ian -I/for-Ingy and me    -I/for-some-Idiocy  ',
  'some crap -I-I-I -I/for-Ian -I/for-Ingy    -I/for-some Idiocy  -I/foo -I/bar ',
  '-I/foo  -I/for-Ian and me -I/for -I/an -I/fu bar',
  ' -I /foo -I /bar',
 );

for my $e2 (@t2) {Inline::C::quote_space($e2)}

if($t2[0] eq '"-I/foo and fu" -I/bar') {print "ok 2\n"}
else {
  warn "\n2\nGot:      **$t2[0]**\n",
           "Expected: **\"-I/foo and fu\" -I/bar**\n";
  print "not ok 2\n";
}

if($t2[1] eq '  -I/foo  "-I/bar   and  baa"     -I/baz  ') {print "ok 3\n"}
else {
  warn "\n3\nGot:      **$t2[1]**\n",
           "Expected: **  -I/foo  \"-I/bar   and  baa\"     -I/baz  **\n";
  print "not ok 3\n";
}

if($t2[2] eq ' -I/foo and fu -I" - I/? ') {print "ok 4\n"}
else {
  warn "\n4\nGot:      **$t2[2]**\n",
           "Expected: ** -I/foo and fu -I\" - I/? **\n";
  print "not ok 4\n";
}

if($t2[3] eq '   -I/for-Ian "-I/for-Ingy and me"    -I/for-some-Idiocy  ') {print "ok 5\n"}
else {
  warn "\n5\nGot:      **$t2[3]**\n",
           "Expected: **   -I/for-Ian \"-I/for-Ingy and me\"    -I/for-some-Idiocy  **\n";
  print "not ok 5\n";
}

if($t2[4] eq '"some crap" -I-I-I -I/for-Ian -I/for-Ingy    "-I/for-some Idiocy"  -I/foo -I/bar ') {print "ok 6\n"}
else {
  warn "\n6\nGot:      **$t2[4]**\n",
           "Expected: **\"some crap\" -I-I-I -I/for-Ian -I/for-Ingy    \"-I/for-some Idiocy\"  -I/foo -I/bar **\n";
  print "not ok 6\n";
}

if($t2[5] eq '-I/foo  "-I/for-Ian and me" -I/for -I/an "-I/fu bar"') {print "ok 7\n"}
else {
  warn "\n7\nGot:      **$t2[5]**\n",
           "Expected: **-I/foo  \"-I/for-Ian and me\" -I/for -I/an \"-I/fu bar\"**\n";
  print "not ok 7\n";
}

if($t2[6] eq ' "-I/foo" "-I/bar"') {print "ok 8\n"}
else {
  warn "\n8\nGot:      **$t2[6]**\n",
           "Expected: ** \"-I/foo\" \"-I/bar\"**\n";
  print "not ok 8\n";
}

$ENV{NO_INSANE_DIRNAMES} = 1;

my $got = Inline::C::quote_space('-I/foo and fu -I/bar');

if($got eq '-I/foo and fu -I/bar') {print "ok 9\n"}
else {
  warn "\n9\nGot:      **$got**\n",
           "Expected: **-I/foo and fu -I/bar**\n";
  print "not ok 9\n";
}

delete $ENV{NO_INSANE_DIRNAMES};

my $have_file_path;
my $newdir = Cwd::getcwd();
$newdir .= '/foo -I/';

eval{require File::Path;};
if($@) {
  warn "\nSkipping remaining tests - couldn't load File::Path\n";
  for(10 .. $t) {print "ok $_\n"}
  exit 0;
}
else {$have_file_path = 1}

unless(File::Path::mkpath($newdir)) {
  unless(-d $newdir) {
    warn "\n Skipping remaining tests - couldn't create $newdir directory.\n",
         "Assuming this platform doesn't support spaces in directory names\n";
    for(10 .. $t) {print "ok $_\n"}
    exit 0;
  }
}

my $stest = " -I/here and there -I$newdir -I/foo -I/bar ";

eval{Inline::C::quote_space($stest);};

if($@ =~ /\/foo \-I\/' directory\./) {print "ok 10\n"}
else {
  warn "\n\$\@: $@\n";
  print "not ok 10\n";
}


END {
  File::Path::rmtree($newdir) if $have_file_path;
  warn "Failed to remove $newdir" if -d $newdir;
};
