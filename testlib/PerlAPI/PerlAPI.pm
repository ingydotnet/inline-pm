package PerlAPI;

use strict;
require Exporter;
@PerlAPI::ISA = qw(Exporter);
@PerlAPI::EXPORT = qw(SvREADONLY_off);
$PerlAPI::VERSION = '0.42';
use Inline C => DATA =>
           PREFIX => 'my_',
           NAME => 'PerlAPI',
           VERSION => '0.42';

1;
__DATA__
__C__
void my_SvREADONLY_off(SV* x) {SvREADONLY_off(x);}

