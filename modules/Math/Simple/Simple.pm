package Math::Simple;
use strict;
require Exporter;
@Math::Simple::ISA = qw(Exporter);
@Math::Simple::EXPORT = qw(add subtract);
$Math::Simple::VERSION = '1.23';

use Inline (C => DATA =>
	    NAME => 'Math::Simple',
	    VERSION => '1.23',
	   );

1;

__DATA__
__C__
int add (int x, int y) {
    return x + y;
}

int subtract (int x, int y) {
    return x - y;
}
