#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 5;
use File::Temp qw(tempdir);
use File::Spec;

# Add the lib directory to @INC so we can load the module
use lib 'lib';

# Test the race condition fix in _mkdir function
BEGIN {
    use_ok('Inline');
}

# Create a temporary directory for testing
my $test_dir = tempdir("inline_race_test_XXXXXX", CLEANUP => 1);
my $target_dir = File::Spec->catdir($test_dir, "_Inline");

# Test 1: Normal directory creation should work
ok(Inline::_mkdir($target_dir, 0777), "Normal directory creation works");
ok(-d $target_dir, "Directory was created successfully");

# Test 2: Race condition simulation - try to create the same directory again
# This should succeed even though the directory already exists
ok(Inline::_mkdir($target_dir, 0777), "Race condition simulation works");

# Test 3: Verify the directory still exists and is writable
ok(-d $target_dir && -w $target_dir, "Directory still exists and is writable");

print "Race condition tests completed successfully!\n"; 
