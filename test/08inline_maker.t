use File::Spec;
use lib (File::Spec->catdir(File::Spec->curdir(),'blib','lib'), File::Spec->curdir());
use strict;
use Test;
use diagnostics;

BEGIN {
  plan(tests => 9);
}

my $example_modules_dir = undef;

# determine if we are using the eg or example directory
if ( -e File::Spec->catdir(File::Spec->curdir(),'eg')) {
  $example_modules_dir = File::Spec->catdir(File::Spec->curdir(),'eg','modules');
  ok(1);
}
elsif ( -e File::Spec->catdir(File::Spec->curdir(),'example')) {
  $example_modules_dir = File::Spec->catdir(File::Spec->curdir(),'example','modules');
  ok(1);
}
else {
  print "# failed to find either the 'example' or 'eg' directory.\n";
  ok(0);
  exit;
}

my $lib_dir  = File::Spec->rel2abs(File::Spec->catdir(File::Spec->curdir(),'lib'));
my $inst_dir = File::Spec->rel2abs(File::Spec->catdir(File::Spec->curdir(),'_Inline_test'));



# chdir to modules and grab each of the names for use later
chdir $example_modules_dir;
my @modules = glob '*';


# loop the list of modules and try to build them.
for my $module (@modules) {

  # cd to module directory
  chdir File::Spec->catdir($module);

  # check that Makefile creation succeeds;
  my $cmd = "$^X -I$lib_dir Makefile.PL INSTALL_BASE=$inst_dir 2>&1";

  my $output = `$cmd`;
  my $create_makefile_exit_status = $? >> 8;
  ok(!$create_makefile_exit_status);

  # check that  '$Config{make} test' succeeds;
  $output = `make test 2>&1`;
  my $make_test_exit_status = $? >> 8;
  ok(!$make_test_exit_status);

  # check that  '$Config{make} install' succeeds;
  $output = `make install 2>&1`;
  my $make_install_exit_status = $? >> 8;
  ok(!$make_install_exit_status);

  # check that  '$Config{make} realclean' succeeds;
  $output = `make realclean 2>&1`;
  my $make_clean_exit_status = $? >> 8;
  ok(!$make_clean_exit_status);

  # go back up to the modules directory so that we can start on the next one.
  chdir File::Spec->updir;
}


