use integer;
use Inline C;

$x = 42;      print '$x is', check($x);
$y = "Ingy";  print '$y is', check($y);
$z = "$x";    print '$x is', check($x);
$z = $y + 1;  print '$y is', check($y);

sub check {
  return (is_int($_[0]) ? '' : ' NOT') . " an int and is",
         (is_str($_[0]) ? '' : ' NOT') . " a string\n";
}
__END__
__C__
int is_int(SV* x) {return SvIOK(x);}
int is_str(SV* x) {return SvPOK(x);}
