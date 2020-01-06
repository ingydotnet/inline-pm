use strict; use warnings;
package TestMLBridge;
use base 'TestML::Bridge';

use Inline;
use File::Spec::Functions qw(rel2abs abs2rel);

sub derive_minus_i {
    my ($self, $perl) = @_;

    local @INC = @INC;
    eval $perl;

    my @paths = map abs2rel($_), grep {
        $_ ne rel2abs('lib') &&
        $_ ne rel2abs('test') &&
        $_ ne rel2abs('../testml/src/perl5/lib')
    } Inline->derive_minus_I;

    join '', map "$_\n", @paths;
}

1;
