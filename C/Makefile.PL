use strict;
use ExtUtils::MakeMaker;
use Config;

my ($cc, $exe) = @Config{'cc', '_exe'};
$cc =~ s/\s+-.+$//; #remove possible trailing options

my $found = 0;
my $delim = $^O eq 'MSWin32' ? ';' : ':';
if ($cc =~ m|/|) {
    $found = -f "$cc$exe";
}
else {
    for my $lib (split $delim, $ENV{PATH}) {
	$found = -f "$lib/$cc$exe" and last;
    }
}

print <<END;

Inline::C is packaged with Inline.pm because it is the most commonly used
Inline language module. See also: Inline::CPP (C++), ::Java, ::Python, 
::Tcl, ::ASM, and ::CPR.

Config.pm indicates that your version of Perl was built with this C compiler:

    $cc$exe

END

if ($found) {
    print <<END;
I have located this compiler on your system:

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
		  VERSION_FROM => 'C.pm',
		  clean => {FILES => '_Inline_test/'},
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
