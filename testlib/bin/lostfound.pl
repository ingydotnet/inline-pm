use Inline C;

$x = q{"Everybody Loves My Ingy"};
$x = 42;
find_string($x);
print "My favorite number is $x\n";

__END__
__C__
void find_string(SV* x) { SvPOK_on(x); }
