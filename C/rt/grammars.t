# Test both parser implementations to ensure they work the same
use strict;
use Test;
use YAML;
use File::Spec;

use blib;
require Inline::C::ParseRecDescent;
require Inline::C::ParseRegExp;

# Do all the typemap foo that Inline::C does
require Inline::C;
use Config;
my $typemap = File::Spec->catfile($Config::Config{installprivlib},"ExtUtils","typemap")
  if -f File::Spec->catfile($Config::Config{installprivlib},"ExtUtils","typemap");
my $o = bless {}, 'Inline::C';
push @{$o->{ILSM}{MAKEFILE}{TYPEMAPS}}, $typemap;
$o->get_types;

# Create new instances of each parser
my $recdescent = Inline::C::ParseRecDescent->get_parser();
my $regexp = Inline::C::ParseRegExp->get_parser();

$recdescent->{data}{typeconv} = $o->{ILSM}{typeconv};
$regexp->{data}{typeconv} = $o->{ILSM}{typeconv};

my @test_objects = @{YAML::Load($Inline::cases)};
plan(tests=>scalar @test_objects);

for my $case (@test_objects) {
    my $input = $case->{input};

    my @outputs;
    for ($recdescent, $regexp) {
        # Without a fresh copy of these objects, the same stuff is parsed over
        # and over.  However, because Parse::RecDescent is sllloooww, we can't
        # just construct a new object over and over. Hence, new() 'em up top,
        # and then clone them here.
        my $parser = deep_clone($_);
        $parser->code($input);
        delete $parser->{data}{typeconv};
        push @outputs, YAML::Store($parser->{data});
    }

    my $expected = YAML::Store($case->{output});
    ok($outputs[0], $outputs[1], "RecDescent didn't match RegExp for $input");
    ok($outputs[1], $expected, "RegExp structure mismatch for $input");
}

use Data::Dumper;
sub deep_clone {
    my $VAR1;
    eval Dumper($_[0]);
    $VAR1
}

BEGIN {
$Inline::cases = q[---
-
 input: void simplest() { }
 output: &simplest
    done:
      simplest: 1
    function:
      simplest:
        arg_names: []
        arg_types: []
        return_type: void
    functions:
      - simplest
-
 input: void simplest() {
 output: *simplest
#-
# Surely this should work...
# input: void simplest();
# output: *simplest
-
 input: |
  void
  simplest
  (
  )
  {
 output: *simplest
-
 input: |
    void simplest() {
        with_a_body__too();
    }
 output: *simplest
-
 input: |
    /* C comment */
    void simplest() {
 output: *simplest
-
 input: |
    void simplest() { }
    /* void bogus() { } */
 output: *simplest
-
 input: |
    // C++/C99 comment...
    void simplest() {
 output: *simplest
-
 input: |
    void simplest() { }
    // void bogus() { }
 output: *simplest
# How does Inline handle user-defined types?  Neither of the parsers seem to
# support it... am I missing something?
#-
# input: "void f(UserDefinedType* t) { }"
# output:
#    done:
#      f: 1
#    function:
#      f:
#        arg_names: ['t']
#        arg_types: ['UserDefinedType']
#        return_type: void
#    functions:
#      - f
-
 input: int with_return_value() {
 output:
    done:
      with_return_value: 1
    function:
      with_return_value:
        arg_names: []
        arg_types: []
        return_type: int
    functions:
      - with_return_value
-
 input: void takes_a_char_star(char* name) {
 output:
    done:
      takes_a_char_star: 1
    function:
      takes_a_char_star:
        arg_names: ['name']
        arg_types: ['char *']
        return_type: void
    functions:
      - takes_a_char_star
-
 input: |
    int addem(int x, int y) {
        return x + y;
    }
 output:
    done:
      addem: 1
    function:
      addem:
        arg_names:
          - x
          - y
        arg_types:
          - int
          - int
        return_type: int
    functions:
      - addem
-
 input: |
    void a() { }
    void b() { }
    void c() { }
 output:
    done:
      a: 1
      b: 1
      c: 1
    function:
      a:
        arg_names: []
        arg_types: []
        return_type: void
      b:
        arg_names: []
        arg_types: []
        return_type: void
      c:
        arg_names: []
        arg_types: []
        return_type: void
    functions:
      - a
      - b
      - c
];
}
