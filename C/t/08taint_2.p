BEGIN {is(${^TAINT}, 1, '2: taint_is_on');};

use Inline Config =>
    UNTAINT => 1,
    DIRECTORY => '_Inline_test';

Inline->bind(C => <<'END');

int incr(int x) {
    return x + 1;
}
END

is(incr(incr(7)), 9, 'incr_test');

1;
