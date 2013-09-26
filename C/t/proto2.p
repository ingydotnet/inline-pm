use warnings;
use strict;

package PROTO2;

use Inline C => Config =>
     DIRECTORY => '_Inline_test',
     #PROTOTYPES => 'ENABLE',
     PROTOTYPE => {foo => '$'},
     #BUILD_NOISY => 1,
     #CLEAN_AFTER_BUILD => 0,
     ;

use Inline C => <<'EOC';

int foo(SV * x) {
     return 23;
}

EOC

my $x = foo(1, 2);
