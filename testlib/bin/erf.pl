use Inline C => DATA =>
           LIBS => '-lm',
           ENABLE => 'AUTOWRAP';

print erf(0), "\n";
print erf(1), "\n";

__END__
__C__
double erf(double);
