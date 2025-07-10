#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 4;
use File::Temp qw(tempdir);
use File::Spec;
use POSIX qw(:sys_wait_h);

# Add the lib directory to @INC so we can load the module
use lib 'lib';

# Test the race condition fix in _mkdir function with multiple processes
BEGIN {
    use_ok('Inline');
}

# Create a temporary directory for testing
my $test_dir = tempdir("inline_race_test_XXXXXX", CLEANUP => 1);
my $target_dir = File::Spec->catdir($test_dir, "_Inline");

# Test: Multiple processes trying to create the same directory
my $num_processes = 5;
my @pids;
my $success_count = 0;

# Fork multiple processes to simulate race condition
for my $i (1..$num_processes) {
    my $pid = fork();
    if ($pid == 0) {
        # Child process
        my $result = Inline::_mkdir($target_dir, 0777);
        exit($result ? 0 : 1);
    } elsif ($pid > 0) {
        # Parent process
        push @pids, $pid;
    } else {
        # Fork failed
        die "Fork failed: $!";
    }
}

# Wait for all child processes to complete
for my $pid (@pids) {
    my $status;
    waitpid($pid, 0);
    $status = $?;
    if (WIFEXITED($status) && WEXITSTATUS($status) == 0) {
        $success_count++;
    }
}

# All processes should have succeeded (either created the directory or found it existing)
ok($success_count == $num_processes, "All $num_processes processes succeeded");
ok(-d $target_dir, "Directory exists after race condition test");
ok(-w $target_dir, "Directory is writable after race condition test");

print "Multi-process race condition test completed successfully!\n";
print "All $num_processes processes succeeded in creating/accessing the directory.\n"; 
