use strict; use warnings;
package TestInlineSetup;

use diagnostics;
use File::Path;

sub import {
    my ($package, $option) = @_;
    $option ||= '';
}

my $inline_dir;
BEGIN {
    ($_, $inline_dir) = caller(2);
    $inline_dir =~ s/.*?(\w+)\.t$/$1/ or die;
    $inline_dir = "_Inline_$inline_dir";
    rmtree($inline_dir) if -d $inline_dir;
    mkdir($inline_dir) or die;
}

END {
    rmtree($inline_dir);
}

1;
