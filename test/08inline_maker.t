use File::Spec;
use strict;
use IPC::Cmd qw/run/;
use Config;
use Test::More;
use diagnostics;

my $example_modules_dir = undef;

# determine if we are using the eg or example directory
if ( -e File::Spec->catdir(File::Spec->curdir(),'eg')) {
  $example_modules_dir = File::Spec->catdir(File::Spec->curdir(),'eg','modules');
}
elsif ( -e File::Spec->catdir(File::Spec->curdir(),'example')) {
  $example_modules_dir = File::Spec->catdir(File::Spec->curdir(),'example','modules');
}

if ($example_modules_dir) {
  plan tests => 8;
}
else {
  plan skip_all => "No modules to test, couldn't find the 'example' or 'eg' directory.";
}

my $lib_dir  = File::Spec->rel2abs(File::Spec->catdir(File::Spec->curdir(),'lib'));
my $inst_dir = File::Spec->rel2abs(File::Spec->catdir(File::Spec->curdir(),'_Inline_test'));

# chdir to modules and grab each of the names for use later
my @modules = glob "$example_modules_dir/*";

# loop the list of modules and try to build them.
for my $module (@modules) {

  # cd to module directory
  chdir File::Spec->rel2abs(File::Spec->catdir(File::Spec->curdir(),$module));

  # check that Makefile creation succeeds;
  my $cmd = [$^X, "-I$lib_dir", 'Makefile.PL', "INSTALL_BASE=$inst_dir"];

  my @result = run( command => $cmd, verbose => 0);

  ok($result[0], 'Makefile creation should succeed');

  # check that  '$Config{make} test' succeeds;
  my $test_cmd = ["$Config{make}", 'test'];
  my @test_result = run ( command => $test_cmd, verbose => 0);
  ok($test_result[0], "'make test' should succeed");

  # check that  '$Config{make} install' succeeds;
  my $install_cmd = ["$Config{make}", 'install'];
  my @install_result = run( command => $install_cmd, verbose => 0);
  ok($install_result[0], "'make install' should succeed");

  # check that  '$Config{make} realclean' succeeds;
  my $clean_cmd = ["$Config{make}", 'realclean'];
  my @clean_result = run( command => $clean_cmd, verbose => 0);
  ok($clean_result[0], "'make realclean' should succeed");
}


