#!/usr/bin/perl
use CGI qw(:standard);
use Inline Config =>
           DIRECTORY => '/usr/local/apache/Inline';
print (header,
       start_html('Inline CGI Example'),
       h1(JAxH('Inline')),
       end_html
      );

use Inline C => <<END;
SV* JAxH(char* x) {
    return newSVpvf("Just Another %s Hacker", x);
}
END
