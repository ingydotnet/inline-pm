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
my $typemap = File::Spec->catfile($Config::Config{installprivlib},
                                  'ExtUtils', 'typemap');
my $o = bless {}, 'Inline::C';
push @{$o->{ILSM}{MAKEFILE}{TYPEMAPS}}, $typemap
  if -f $typemap;
$o->get_types;

# Create new instances of each parser
my $recdescent = Inline::C::ParseRecDescent->get_parser();
my $regexp = Inline::C::ParseRegExp->get_parser();

$recdescent->{data}{typeconv} = $o->{ILSM}{typeconv};
$regexp->{data}{typeconv} = $o->{ILSM}{typeconv};

my @test_objects = @{YAML::Load($Inline::cases)};
plan(tests => 2 * @test_objects);

for my $case (@test_objects) {
    my $input = $case->{input};
    my $expect = $case->{expect};

    my @outputs;
    for ($recdescent, $regexp) {
        # Without a fresh copy of these objects, the same stuff is parsed over
        # and over.  However, because Parse::RecDescent is sllloooww, we can't
        # just construct a new object over and over. Hence, new() 'em up top,
        # and then clone them here.
        my $parser = deep_clone($_);
        $parser->code($input);
        delete $parser->{data}{typeconv};
        my $output = YAML::Dump($parser->{data});
        $output =~ s/^---.*\n//;
        push @outputs, $output;
    }

    ok($outputs[0], $expect, "ParseRecDescent failed for:$input\n");
    ok($outputs[1], $expect, "ParseRegExp failed for:$input\n");
}

use Data::Dumper;
sub deep_clone {
    my $VAR1;
    eval Dumper($_[0]);
    $VAR1
}

BEGIN {
($Inline::cases, undef) = (<<END, <<END);
- input: long get_serial(SV* obj) {
  expect: |
    done:
      get_serial: 1
    function:
      get_serial:
        arg_names:
          - obj
        arg_types:
          - SV *
        return_type: long
    functions:
      - get_serial

- input: SV* new(char* class, char* name, char* rank, long serial) {
  expect: |
    done:
      new: 1
    function:
      new:
        arg_names:
          - class
          - name
          - rank
          - serial
        arg_types:
          - char *
          - char *
          - char *
          - long
        return_type: SV *
    functions:
      - new

- input: |
    unsigned foo (unsigned int a, 
                  unsigned short b,
                  unsigned char c, 
                  unsigned char * d) {
  expect: |
    done:
      foo: 1
    function:
      foo:
        arg_names:
          - a
          - b
          - c
          - d
        arg_types:
          - unsigned int
          - unsigned short
          - unsigned char
          - unsigned char *
        return_type: unsigned
    functions:
      - foo

- input: long Foo5(int i, int j, ...) { return 3; }
  expect: |
    done:
      Foo5: 1
    function:
      Foo5:
        arg_names:
          - i
          - j
          - '...'
        arg_types:
          - int
          - int
          - '...'
        return_type: long
    functions:
      - Foo5

- input: char *func(char *x, char* y, char  *  z) {
  expect: |
    done:
      func: 1
    function:
      func:
        arg_names:
          - x
          - y
          - z
        arg_types:
          - char *
          - char *
          - char *
        return_type: char *
    functions:
      - func

- input: unsigned func(unsigned arg) {
  expect: |
    done:
      func: 1
    function:
      func:
        arg_names:
          - arg
        arg_types:
          - unsigned
        return_type: unsigned
    functions:
      - func

- input: void simplest() { }
  expect: &simplest |
    done:
      simplest: 1
    function:
      simplest:
        arg_names: []
        arg_types: []
        return_type: void
    functions:
      - simplest

- input: void simplest() {
  expect: *simplest
- input: |
    void
    simplest
    (
    )
    {
  expect: *simplest

- input: |
    void simplest() {
        with_a_body__too();
    }
  expect: *simplest

- input: |
    /* C comment */
    void simplest() {
  expect: *simplest

- input: |
    void simplest() { }
    /* void bogus() { } */
  expect: *simplest

- input: |
    // C++/C99 comment...
    void simplest() {
  expect: *simplest

- input: |
    void simplest() { }
    // void bogus() { }
  expect: *simplest

- input: int with_return_value() {
  expect: |
    done:
      with_return_value: 1
    function:
      with_return_value:
        arg_names: []
        arg_types: []
        return_type: int
    functions:
      - with_return_value

- input: void takes_a_char_star(char* name) {
  expect: |
    done:
      takes_a_char_star: 1
    function:
      takes_a_char_star:
        arg_names:
          - name
        arg_types:
          - char *
        return_type: void
    functions:
      - takes_a_char_star

- input: |
    int addem(int x, int y) {
        return x + y;
    }
  expect: |
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

- input: |
    void a() { }
    void b() { }
    void c() { }
  expect: |
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

END
END
}
