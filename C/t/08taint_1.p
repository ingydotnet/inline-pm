BEGIN {is(${^TAINT}, 1, '1: taint_is_on');};

use Inline Config =>
    UNTAINT => 1,
    DIRECTORY => '_Inline_test';

use Inline C => <<'END_OF_C_CODE';

int add(int x, int y) {
    return x + y;
}

END_OF_C_CODE

is(add(7,3), 10, 'add_test');

1;
