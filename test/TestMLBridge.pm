use strict; use warnings;
package TestMLBridge;
use base 'TestML::Bridge';

use Inline;
use File::Spec::Functions qw(abs2rel catdir);

sub derive_minus_i {
    my ($self, $perl, $paths) = @_;

    mkdir 'doc';
    mkdir 'eg';

    local @INC = @INC;
    eval $perl;

    my @got = map abs2rel($_), Inline->derive_minus_I;

    my $out = '';
    for my $path (split /\n/, $paths) {
        $out .= "$path\n" if grep { $path eq $_ } @got;
    }

    return $out;
}

sub eval_catch {
    my ($self, $perl) = @_;
    eval $perl;
    return $@;
}

1;
