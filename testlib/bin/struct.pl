use Inline C => DATA => 
           STRUCTS => ['Foo'];

my $foo = Inline::Struct::Foo->new;
$foo->num(10);
$foo->str("Hello");

myfunc($foo);

__END__
__C__
struct Foo {
    int num;
    char* str;
};
typedef struct Foo Foo;

void myfunc(Foo* foo) {
    printf("myfunc: num=%i, str='%s'\n", 
           foo->num, foo->str);
}
