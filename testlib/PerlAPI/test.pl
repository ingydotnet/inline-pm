use Test;
use PerlAPI;
plan(tests => 1);

$str = \ "Ingy hates Inline\n";
SvREADONLY_off($$str);
$$str =~ s/hate/love/g;

ok ($$str =~ /loves/);
