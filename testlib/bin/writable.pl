use Inline C;
$str = \ "Ingy hates Inline\n";
writable($$str);
$$str =~ s/hate/love/g;
print $$str;

__END__
__C__
void writable(SV* x) {SvREADONLY_off(x);}
