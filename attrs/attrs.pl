package main;
BEGIN { print "before\n" }
use Foo 'attributes';

END   { print "END\n"   }
      { print "main\n"  }
INIT  { print "INIT\n"  }
CHECK { print "CHECK\n" }
BEGIN { print "BEGIN\n" }

print foo(1,2,3);

sub foo :inline('int foo(int x)') {q{
    x *= 3;
    return x;
}}

__END__

use Inline 'attributes';
use Inline C => ALL =>
           NAME => 'Foo::Bar',
           VERSION => '1.23';

use Inline C => <<END;
void foo() {
    ...
}
END

sub bar : inline('int bar(char* s)') {
    ...
}

__END__
__C__
int baz() {
    ...
}
