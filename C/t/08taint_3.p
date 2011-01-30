BEGIN {is(${^TAINT}, 1, '3: taint_is_on');};

use Inline C;
use Inline C => 'DATA';

Inline->init() ;

use Inline Config =>
    UNTAINT => 1,
    DIRECTORY => '_Inline_test';

is(multiply(3, 7), 21, 'multiply_test');
is(divide(7, -3), -2, 'divide_test');

1;

__DATA__

__C__

int multiply(int x, int y) {
    return x * y;
}

__C__

int divide(int x, int y) {
    return x / y;
}



