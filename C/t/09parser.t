our %conf;

BEGIN {
    warn "This test could take a couple of minutes to run\n";
    if (exists $ENV{PERL_INSTALL_ROOT}) {
	warn "\nIgnoring \$ENV{PERL_INSTALL_ROOT} in $0\n";
	delete $ENV{PERL_INSTALL_ROOT};
	}
    %conf = (
	main	=> {
	    foo_	=> -1,
	    _foo_	=> -3,
	    _foo	=>  2,
	    foo		=>  1,
	    bar		=>  2,
	    baz		=>  3,
	    foobar	=>  4,
	    foobarbaz	=>  5,
	    },
	FOO => {
	    foo		=>  6,
	    },
	BAR => {
	    bar		=>  7,
	    },
	BAZ => {
	    baz		=>  8,
	    baz_	=> -2,
	    }
	)
    };

use strict;
use warnings;

use File::Spec;
use lib (File::Spec->catdir (File::Spec->updir  (), "blib", "lib"),
	 File::Spec->catdir (File::Spec->curdir (), "blib", "lib"));

sub code
{
    my ($p, $sym) = @_;
    my $code = <<"EOIC";
package $p;

use Inline C => <<"EOC";

int $sym () { return $conf{$p}{$sym}; }
EOC
EOIC
    # warn "Code: $code";
    eval $code;
    } # code

#use Inline Config =>
#    DIRECTORY => "_Inline_test",
#    _TESTING  => 1;

########## main:foo_ ########
use Inline C => Config =>
    DIRECTORY   => "_Inline_test",
    FORCE_BUILD => 1,
    _TESTING    => 1,
    USING       => "ParseRegExp";

main::code (__PACKAGE__, "foo_");

# Use same Config options as for main::foo()
main::code (__PACKAGE__, "_foo_");

########## main:_foo ########
use Inline C => Config =>
   DIRECTORY   => "_Inline_test",
   FORCE_BUILD => 1,
   _TESTING    => 1,
   USING       => "ParseRecDescent";

main::code (__PACKAGE__, "_foo");

########## main:foo ########
use Inline C => Config =>
   DIRECTORY   => "_Inline_test",
   FORCE_BUILD => 1,
   _TESTING    => 1,
   USING       => "ParseRegExp";

main::code (__PACKAGE__, "foo");

# No USING value specified here - will use default (ParseRecDescent).
use Inline C => Config =>
   DIRECTORY   => "_Inline_test",
   FORCE_BUILD => 1,
   _TESTING    => 1;

main::code (__PACKAGE__, "bar");

########## main:baz ########
use Inline C => Config =>
   DIRECTORY   => "_Inline_test",
   FORCE_BUILD => 1,
   _TESTING    => 1,
   USING       => "ParseRecDescent";

main::code (__PACKAGE__, "baz");

########## main:foobar ########
# No USING value specified here - will use default (ParseRecDescent).
use Inline C => Config =>
   DIRECTORY   => "_Inline_test",
   FORCE_BUILD => 1,
   _TESTING    => 1;

main::code (__PACKAGE__, "foobar");

########## main:foobarbaz ########
# Use same config options as for main::foobar().

main::code (__PACKAGE__, "foobarbaz");

########## FOO::foo ########
package FOO;

use Inline C => Config =>
   DIRECTORY   => "_Inline_test",
   FORCE_BUILD => 1,
   _TESTING    => 1,
   USING       => "ParseRecDescent";

main::code (__PACKAGE__, "foo");

########## BAR::bar ########
package BAR;

use Inline C => Config =>
   DIRECTORY   => "_Inline_test",
   FORCE_BUILD => 1,
   _TESTING    => 1;

main::code (__PACKAGE__, "bar");

########## BAZ::baz ########
package BAZ;

use Inline C => Config =>
   DIRECTORY   => "_Inline_test",
   FORCE_BUILD => 1,
   _TESTING    => 1,
   USING       => "ParseRegExp";

main::code (__PACKAGE__, "baz");

########## BAZ::baz_ ########
# Use same Config options as for BAZ::bar()

main::code (__PACKAGE__, "baz_");

########################################

package main;

use strict;
use warnings;
use Test::More;

is (      foo_ (),       $conf{main}{foo_},      "      foo_     ");
is (      _foo_ (),      $conf{main}{_foo_},     "      _foo_    ");
is (      _foo (),       $conf{main}{_foo},      "      _foo     ");
is (      foo (),        $conf{main}{foo},       "      foo      ");
is (      bar (),        $conf{main}{bar},       "      bar      ");
is (      baz (),        $conf{main}{baz},       "      baz      ");
is (      foobar (),     $conf{main}{foobar},    "      foobar   ");
is (      foobarbaz (),  $conf{main}{foobarbaz}, "      foobarbaz");
is (main::foo_ (),       $conf{main}{foo_},      "main::foo_     ");
is (main::_foo_ (),      $conf{main}{_foo_},     "main::_foo_    ");
is (main::_foo (),       $conf{main}{_foo},      "main::_foo     ");
is (main::foo (),        $conf{main}{foo},       "main::foo      ");
is (main::bar (),        $conf{main}{bar},       "main::bar      ");
is (main::baz (),        $conf{main}{baz},       "main::baz      ");
is (main::foobar (),     $conf{main}{foobar},    "main::foobar   ");
is (main::foobarbaz (),  $conf{main}{foobarbaz}, "main::foobarbaz");
is ( FOO::foo (),        $conf{FOO}{foo},        " FOO::foo      ");
is ( BAR::bar (),        $conf{BAR}{bar},        " BAR::bar      ");
is ( BAZ::baz (),        $conf{BAZ}{baz},        " BAZ::baz      ");
is ( BAZ::baz_ (),       $conf{BAZ}{baz_},       " BAZ::baz_     ");

my $prod = -483840;
my $res = main::foo_ () * main::_foo () * main::_foo_ () * main::foo () *
	  main::bar () * main::baz () * main::foobar () * main::foobarbaz () *
	  FOO::foo () * BAR::bar () * BAZ::baz () * BAZ::baz_ ();

is ($res, $prod, "Returned product");

chomp (my @p = do { local @ARGV = "_Inline_test/parser_id"; <> });

is (scalar @p, 21, "Match number of lines in log");

# diag "@p";
is_deeply (\@p, [
    "Inline::C::get_parser called",
    "Inline::C::ParseRecDescent::get_parser called",
    "Inline::C::get_parser called",
    "Inline::C::ParseRecDescent::get_parser called",
    "Inline::C::get_parser called",
    "Inline::C::ParseRecDescent::get_parser called",
    "Inline::C::get_parser called",
    "Inline::C::ParseRecDescent::get_parser called",
    "Inline::C::get_parser called",
    "Inline::C::ParseRecDescent::get_parser called",
    "Inline::C::get_parser called",
    "Inline::C::ParseRecDescent::get_parser called",
    "Inline::C::get_parser called",
    "Inline::C::ParseRecDescent::get_parser called",
    "Inline::C::get_parser called",
    "Inline::C::ParseRecDescent::get_parser called",
    "Inline::C::ParseRecDescent::get_parser called",
    "Inline::C::get_parser called",
    "Inline::C::ParseRecDescent::get_parser called",
    "Inline::C::ParseRegExp::get_parser called",
    "Inline::C::ParseRegExp::get_parser called",
    ], "parser log");

Inline::C::_testing_cleanup();

done_testing ();
