use Inline::Files;
use Inline C;
print "9 + 5 = ", add(9, 5), "\n\n";
print "SQRT(9^2 + 5^2) = ", pyth(9, 5), "\n\n";
print "9 * 5 = ", mult(9, 5), "\n\n";
__C__
int add(int x, int y) {
    return x + y;
}
static int mult(int x, int y) {
    return x * y;
}
double pyth(int x, int y) {
    return sqrt(add(mult(x, x), mult(y, y)));
}
