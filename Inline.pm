package Inline;

use strict;
require 5.005;
$Inline::VERSION = '0.50';
my $_INSTALL_ = 0;

sub import {
    my ($class, $language, $source, %args) = @_;
    my $package = caller;

    if ($class eq 'Inline' and $language eq 'C' and
	defined $args{NAME} and $args{NAME} eq $package and
	defined $args{VERSION} and not $_INSTALL_
       ) {
	eval "INIT { dynaload('$package') }";
        die $@ if $@;
    }
    else {
	$_INSTALL_ = 1 if $language eq '_INSTALL_';
	eval "require Inline::devel";
	if ($@) {
	    eval "use Carp";
	    Carp::croak(<<ERROR);
Can't find module Inline::devel. 
Try installing the 'Inline' distribution from the CPAN.
ERROR
	}
	goto &import_devel;
    }
}

sub dynaload {
    require DynaLoader;
    my ($package) = @_;
    no strict 'refs';
    push @{"${package}::ISA"}, qw(DynaLoader);
    $package->bootstrap;
}

1;
