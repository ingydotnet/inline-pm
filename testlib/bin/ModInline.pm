package Factorial;
use strict;

use Apache ();
use Apache::Constants qw(:common);

use Inline 'Untaint';
use Inline Config => DIRECTORY => '/usr/local/apache/Inline';
use Inline 'C';
Inline->init;

sub handler {
    my $r = shift;
    $r->send_http_header('text/plain');

    foreach my $num ( 1 .. int rand(150) + 1 ) {
        print $num, "! = ", factorial($num), "\n";
    }

    return OK;
}

1;
__DATA__
__C__

double factorial(double x) {
    if (x < 2)  return 1;
    return x * factorial(x - 1);
}
