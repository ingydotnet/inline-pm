use Inline Global;
use Inline C;
use Inline C;
my ($a, $b) = @ARGV;
print "$a ^ 2 + $b ^ 2 = ", sum_squares($a, $b), "\n";
__END__
__C__
int sum_squares(int a, int b) {
    return squared(a) + squared(b);
}
__C__
int squared(int x) {
    return x * x;
}
