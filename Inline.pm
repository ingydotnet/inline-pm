package Inline;

use strict;
require 5.005;
$Inline::VERSION = '0.50';
use Carp;

sub import {
    my ($class, $language, $source, %args) = @_;
    my ($package) = caller;
    my $version;
    {no strict 'refs'; $version = ${$package . "::version"}}
    if ($class eq 'Inline' and $language eq 'C' and
	defined $args{NAME} and $args{NAME} eq $package and
	defined $args{VERSION} and $args{VERSION} eq $version
       ) {
	dynaload() 
	  or croak "Couldn't dynaload Inline based module $package";
    }
    else {    
	require Inline::devel;
	goto &import_devel;
    }
}

sub dynaload {
    # put dynaloader stuff here.
    # this should be refactored to be Inline::devel's load subroutine and be
    # able to be called both ways.
    0; 
}

1;
