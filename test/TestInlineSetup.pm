use strict; use warnings;
package TestInlineSetup;

our $DIAG =  eval {
    require diagnostics;
    diagnostics->import();
    1;
};

use File::Path;
use File::Spec;

sub import {
    my ($package, $option) = @_;
    $option ||= '';
}

our $DIR;
BEGIN {
    ($_, $DIR) = caller(2);
    $DIR =~ s/.*?(\w+)\.t$/$1/ or die;
    $DIR = "_Inline_$DIR.$$";
    rmtree($DIR) if -d $DIR;
    mkdir($DIR) or die "$DIR: $!\n";
}
my $absdir = File::Spec->rel2abs($DIR);
($absdir) = $absdir =~ /(.*)/; # untaint

my $startpid = $$;
END {
  if($$ == $startpid) { # only when original process exits
    rmtree($absdir);
  }
}

1;
