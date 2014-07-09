use warnings;
use Boo;
use Boo::Far;
use Boo::Far::Faz;

print "1..6\n";

my $str = Boo::boo();

if($str eq "Hello from Boo") {print "ok 1\n"}
else {
  warn "\n\$str: $str\n";
  print "not ok 1\n";
}

$str = Boo::Far::boofar();

if($str eq "Hello from Boo::Far") {print "ok 2\n"}
else {
  warn "\n\$str: $str\n";
  print "not ok 2\n";
}

$str = Boo::Far::Faz::boofarfaz();

if($str eq "Hello from Boo::Far::Faz") {print "ok 3\n"}
else {
  warn "\n\$str: $str\n";
  print "not ok 3\n";
}

if($Boo::VERSION eq '2.01') {print "ok 4\n"}
else {
  warn "\$Boo::VERSION: $Boo::VERSION\n";
  print "not ok 4\n";
}

if($Boo::Far::VERSION eq '2.01') {print "ok 5\n"}
else {
  warn "\$Boo::Far::VERSION: $Boo::Far::VERSION\n";
  print "not ok 5\n";
}

if($Boo::Far::Faz::VERSION eq '2.01') {print "ok 6\n"}
else {
  warn "\$Boo::Far::Faz::VERSION: $Boo::Far::Faz::VERSION\n";
  print "not ok 6\n";
}
