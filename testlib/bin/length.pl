use Inline C;

open FILE, $ARGV[0] or die $!;
undef $/;
print "The length of $ARGV[0] is ",
      len(<FILE>), " characters\n";

__END__
__C__

int len(char* str) {
    return strlen(str);
}
