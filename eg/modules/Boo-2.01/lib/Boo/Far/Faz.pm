package
Boo::Far::Faz;

$Boo::Far::Faz::VERSION = '2.01';

use Inline Config => NAME => 'Boo::Far::Faz' => VERSION => '2.01';

use Inline C => <<'EOC';

SV * boofarfaz() {
  return(newSVpv("Hello from Boo::Far::Faz", 0));
}

EOC

1;
