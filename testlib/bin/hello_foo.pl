use Inline C;

greet('foo');

__END__
__C__

void greet(char* who) {
    printf("Hello, %s\n", who);
}
