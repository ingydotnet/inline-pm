use Inline C => DATA =>
           TYPEMAPS => './typemap';
print '1.2 + 3.4 = ', fadd(1.2, 3.4), "\n";

__END__
__C__
float fadd(float x, float y) {
    return x + y;
}
