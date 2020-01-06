use strict; use warnings;
package TestMLBridge;
use base 'TestML::Bridge';

use Inline;
use File::Spec::Functions qw(abs2rel);

sub derive_minus_i {
    my ($self, $perl) = @_;

    mkdir 'doc';
    mkdir 'eg';

    local @INC = @INC;
    eval $perl;

    join '',
        map "$_\n",
        map abs2rel($_),
        Inline->derive_minus_I;
}

sub eval_catch {
    my ($self, $perl) = @_;
    eval $perl;
    return $@;
}

1;
