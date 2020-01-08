use strict; use warnings;
package TestMLBridge;
use base 'TestML::Bridge';

use Inline;
use File::Spec::Functions qw(abs2rel catdir);

sub derive_minus_i {
    my ($self, $perl, $paths_expected) = @_;

    mkdir 'doc';
    mkdir 'eg';

    local @INC = @INC;
    eval $perl;

    my %paths_got = map { abs2rel($_) => 1 } Inline->derive_minus_I;

    join '',
        map "$_\n",
        grep $paths_got{$_},
        split /\n/, $paths_expected;
}

sub eval_catch {
    my ($self, $perl) = @_;
    eval $perl;
    return $@;
}

1;
