use strict;
use ExtUtils::MakeMaker;
use Config;
use File::Spec;

my ($cc, $exe) = @Config{'cc', '_exe'};
$cc =~ s/\s+-.+$//; #remove possible trailing options

my $found = 0;
my $delim = $Config::Config{path_sep};

if ($cc =~ m|/:\[|) {
    my $comp = (split /\./, $cc)[0];
    $found = -f "$comp$exe";
}

# $Config{cc} might be something like 'ccache cc'
elsif ($cc =~ m|ccache|) {
    my @cc = split /\s+/, $cc;
    $found = 1;
    for (@cc) {
        if (!find_executable($_)) {
            $found = 0;
            last;
        }
    }
}

else {
    $found = find_executable($cc);
}

print <<END;

Inline::C is packaged with Inline.pm because it is the most commonly used
Inline Language Support Module (ILSM).

See also: Inline::ASM, ::Awk, ::BC, ::Basic, ::Befunge, ::CPP (C++), ::CPR,
          ::Foo, ::Guile, ::Java, ::Octave, ::PERL, ::Python, ::Ruby, ::TT,
          ::Tcl and ::WebChat.

Config.pm indicates that your version of Perl was built with this C compiler:

    $cc

END

if ($found) {
    print <<END;
I have located this compiler on your system.

END
}
else {
    print <<END;
I cannot locate this compiler on your system.

You can install Inline.pm without installing Inline::C. But you'll
need to install another Inline language module (like Inline::Java for
instance) to actually make use of it.

If the aforementioned C compiler really is on your system, please make sure
it can be found in the PATH and then try running this program again. Or if
you think I made an error searching for this compiler, simply answer 'Y' to
the next question.

END
# '
}

my $answer = '';
my $default = $found ? "y" : "n";
while (1) {
    $answer = prompt ('Do you want to install Inline::C?', $default);
    last if $answer =~ /^(y|yes|n|no)$/i;
}

if ($answer =~ /^(y|yes)$/i) {
    WriteMakefile(
                  NAME => 'Inline::C',
                  clean => {FILES => '_Inline_test'},
                 )
}
else {
    open MF, "> Makefile" or die "Can't open Makefile for output";
    print MF <<'END';
all::
test::
clean::
END
    close MF;
}

sub find_executable {
    return 1 if -e $_[0];
    my($cc) = @_;
    my $comp = (split /\./, $cc)[0];

    # $Config{cc} might be something like '/some/place/cc'
    if ($cc =~ m|/|) {
        return -f "$comp$exe" || -l $cc;
    }

    for my $lib (split $delim, $ENV{PATH}) {
	return 1 if -f File::Spec->catfile($lib,"$comp$exe");
    }
}
