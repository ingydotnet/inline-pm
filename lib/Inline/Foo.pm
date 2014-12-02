use strict;
package Inline::Foo;

require Inline;
our @ISA = qw(Inline);
our $VERSION = '0.78';

use Carp;
use File::Spec;

sub register {
    return {
        language => 'Foo',
        aliases => ['foo'],
        type => 'interpreted',
        suffix => 'foo',
    };
}

sub usage_config {
    my $key = shift;
    "'$key' is not a valid config option for Inline::Foo\n";
}

sub usage_config_bar {
    "Invalid value for Inline::Foo config option BAR";
}

sub validate {
    my $o = shift;
    $o->{ILSM}{PATTERN} ||= 'foo-';
    $o->{ILSM}{BAR} ||= 0;
    while (@_) {
        my ($key, $value) = splice @_, 0, 2;
        if ($key eq 'PATTERN') {
            $o->{ILSM}{PATTERN} = $value;
            next;
        }
        if ($key eq 'BAR') {
            croak usage_config_bar
              unless $value =~ /^[01]$/;
            $o->{ILSM}{BAR} = $value;
            next;
        }
        croak usage_config($key);
    }
}

sub build {
    my $o = shift;
    my $code = $o->{API}{code};
    my $pattern = $o->{ILSM}{PATTERN};
    $code =~ s/$pattern//g;
    $code =~ s/bar-//g if $o->{ILSM}{BAR};
    {
        package Foo::Tester;
        our $VERSION = '0.02';
        eval $code;
    }
    croak "Foo build failed:\n$@" if $@;
    my $path = File::Spec->catdir($o->{API}{install_lib},'auto',$o->{API}{modpname});
    my $obj = $o->{API}{location};
    $o->mkpath($path) unless -d $path;
    open FOO_OBJ, "> $obj"
      or croak "Can't open $obj for output\n$!";
    print FOO_OBJ $code;
    close \*FOO_OBJ;
}

sub load {
    my $o = shift;
    my $obj = $o->{API}{location};
    open FOO_OBJ, "< $obj"
      or croak "Can't open $obj for output\n$!";
    my $code = join '', <FOO_OBJ>;
    close \*FOO_OBJ;
    eval "package $o->{API}{pkg};\n$code";
    croak "Unable to load Foo module $obj:\n$@" if $@;
}

sub info {
    my $o = shift;
}

1;
