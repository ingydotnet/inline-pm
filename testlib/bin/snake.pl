use Inline Python;
my $language = shift;
print $language,
      (match($language, 'Perl') ? ' rules' : ' sucks'),
      "!\n";
__END__
__Python__
import sys
import re
def match(str, regex):
    f = re.compile(regex);
    if f.match(str): return 1
    return 0
