use strict;
use Cwd;
use Inline Java => 'STUDY',
           CLASSPATH => cwd() . '/class',
           STUDY => ['squarer'];

my $s = new squarer();
my $n = 7;

print "$n squared is ", $s->square($n), "\n" ;
