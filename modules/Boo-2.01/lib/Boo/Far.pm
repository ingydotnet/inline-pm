package
Boo::Far;

$Boo::Far::VERSION = '2.01';

use Inline Config => NAME => 'Boo::Far' => VERSION => '2.01';

use Inline C => <<'EOC';

SV * boofar() {
  return(newSVpv("Hello from Boo::Far", 0));
}

EOC

1;
