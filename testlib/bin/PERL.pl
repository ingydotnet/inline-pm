use Inline::Files;
use Inline PERL;

greeting("PERL");

__PERL__
sub greeting {
    $foo = shift @_ || $_[0];

    $! = 1; # Turn buffering off

    for ($i=1, $i<=10, $i++) {
        @a[$i] = $i;
    }

    local $length = @a.length;
    
    print "Hello, $foo\n";
}
