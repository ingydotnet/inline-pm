use Inline C => DATA =>
           LIBS => '-luser32',
           PREFIX => 'my_';
MessageBoxA('Inline Message Box', 
            'Just Another Perl Hacker');

__END__
__C__
#include <windows.h>
int my_MessageBoxA(char* Caption, char* Text) {
  return MessageBoxA(0, Text, Caption, 0);
}
