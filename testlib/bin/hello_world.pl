use Inline C => <<'END_C';

#include <stdio.h>

void greet() {
    printf("Hello, world\n");
}

END_C

greet;
