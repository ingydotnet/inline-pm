# Test both parser implementations to ensure they work the same
use strict;
use Test;
use YAML;

# Note: These are unqualified so that they use the copies from the immediate
# parent dir.
use recdescent;
use charity;

# Do all the typemap foo that Inline::C does
require Inline::C;
use Config;
my $typemap = "$Config::Config{installprivlib}/ExtUtils/typemap"
  if -f "$Config::Config{installprivlib}/ExtUtils/typemap";
my $o = bless {}, 'Inline::C';
push @{$o->{ILSM}{MAKEFILE}{TYPEMAPS}}, $typemap;
$o->get_types;

# Create new instances of each parser
my $recdescent = Inline::C::recdescent->new();
my $charity = Inline::C::charity->new();

$recdescent->{data}{typeconv} = $o->{ILSM}{typeconv};
$charity->{data}{typeconv} = $o->{ILSM}{typeconv};

my @test_objects = @{YAML::Load(join '', <DATA>)};
plan(tests=>scalar @test_objects);

for my $case (@test_objects) {
    my $input = $case->{input};

    my @outputs;
    for ($recdescent, $charity) {
	# Without a fresh copy of these objects, the same stuff is parsed over
	# and over.  However, because Parse::RecDescent is sllloooww, we can't
	# just construct a new object over and over. Hence, new() 'em up top,
	# and then clone them here.
	my $parser = deep_clone($_);
	$parser->code($input);
	delete $parser->{data}{typeconv};
	push @outputs, YAML::Store($parser->{data});
    }

    ok($outputs[0], $outputs[1], "Failed while testing: $input");
    # XXX Why doesn't this work?
    # ok(@outputs, "Failed while testing: $input");
}

use Data::Dumper;
sub deep_clone {
    my $VAR1;
    eval Dumper($_[0]);
    $VAR1
}

__DATA__
-
 input: void simplest() { }
-
 input: void without_closing_curly() {
-
 input: |
    void with_body() {
	foo();
    }
-
 input: int with_return_value() {
-
 input: void takes_a_char_star(char* name) {
-
 input: |
    int addem(int x, int y) {
        return x + y;
    }
-
 input: |
    /* C comment */
    void f(void)
-
 input: |
    void a() { }
    void b() { }
    void c() { }
