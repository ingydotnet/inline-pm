# Test both parser implementations to ensure they work the same
use Test;
use YAML;
use Inline::C::recdescent;
use Inline::C::charity;

# Do all the typemap foo that Inline::C does
require Inline::C;
use Config;
$typemap = "$Config::Config{installprivlib}/ExtUtils/typemap"
  if -f "$Config::Config{installprivlib}/ExtUtils/typemap";
my $o = bless {}, 'Inline::C';
push @{$o->{ILSM}{MAKEFILE}{TYPEMAPS}}, $typemap;
$o->get_types;

# Create new instances of each parser
my $recdescent = Inline::C::recdescent->new();
$recdescent->{data}{typeconv} = $o->{ILSM}{typeconv};
my $charity = Inline::C::charity->new();
$charity->{data}{typeconv} = $o->{ILSM}{typeconv};

# Perform tests (defined below)
my @test_objects = YAML::Load(join '', <DATA>);
plan(tests=>scalar @test_objects);

for (@test_objects) {
    $recdescent->code($_->{code});
    $charity->code($_->{code});
    delete($recdescent->{data}{typeconv});
    delete($charity->{data}{typeconv});
    ok(Store($recdescent->{data}),
       Store($charity->{data}),
       "Failed while testing: $_->{abstract}"
      );
}

__DATA__
---
abstract: Simple function with 1 arg
code: |
    void greet(char* name) {
        printf("hello %s\n");
    }
---
abstract: Function with a return type
code: |
    int addem(int x, int y) {
        return x + y;
    }
