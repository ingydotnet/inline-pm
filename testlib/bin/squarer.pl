use strict;
use Cwd;
use Inline Java => 'DATA',
           CLASSPATH => cwd() . '/class';

my $s = new my_squarer();
my $n = 6;

print "$n squared is ", $s->square($n), "\n";

__END__
__Java__
class my_squarer extends squarer {
    public my_squarer() {
        super();
    }
}
