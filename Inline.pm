package Inline;

use strict;
require 5.005;
$Inline::VERSION = '0.50';
use Carp;

sub import {
    my ($class, $language, $source, %args) = @_;
    my $package = caller;
    my $version;
    {no strict 'refs'; $version = ${"${package}::VERSION"}}

    if ($class eq 'Inline' and $language eq 'C' and
	defined $args{NAME} and $args{NAME} eq $package and
	defined $args{VERSION} and $args{VERSION} eq $version
       ) {
	dynaload($package, $version);
    }
    else {
	require Inline::devel;
	goto &import_devel;
    }
}

sub dynaload {
    require DynaLoader;
    my ($package, $version) = @_;
    no strict 'refs';
    push @{"${package}::ISA"}, qw(DynaLoader);
    $package->bootstrap;
    croak "Couldn't dynaload Inline based module $package.\n$@" if $@;
}

1;
