package Inline;

use strict;
require 5.005;
$Inline::VERSION = '0.43';

sub import {
    require Inline::devel;
    goto &import_devel;
}

1;
