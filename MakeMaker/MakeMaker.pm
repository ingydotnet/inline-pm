package Inline::MakeMaker;
use strict;
use Carp;
use Config;
$Inline::MakeMaker::VERSION = '0.41';

my ($package, $filename, @modules, @versions);

sub usage_postamble {
    return "\n\nWhen using Inline::MakeMaker, it is illegal to define &MY::postamble.\n\n";
}

sub postamble {
    return 'roger' if $_[0] eq 'testing';
    my $name = pop @modules
      or croak "Missing module name in Inline::MakeMaker::postamble\n";
    my $version = pop @versions
      or croak "Missing module version in Inline::MakeMaker::postamble\n";
    my @parts = split /::/, $name;
    my $subpath = join '/', @parts;
    my $object = $parts[-1];
    my $so = $Config::Config{so};
    return <<END;

.SUFFIXES: .pm .inl

.pm.inl:
	\$(PERL) -Mblib -MInline=_INSTALL_ -M$name -e1 $version \$(INST_ARCHLIB)

pure_all :: $object.inl

END
}

END {
    local $" = "\n";
    croak <<END if @modules > 0;
The following Inline modules were not properly handled my Inline::MakeMaker:

@modules
END
}

sub import {
    ($package, $filename) = caller;
    require ExtUtils::MakeMaker;
    no strict 'refs';
    *MY::postamble = \&Inline::MakeMaker::postamble;
    *{"${package}::WriteInlineMakefile"} = \&Inline::MakeMaker::WriteInlineMakefile;
}

sub WriteInlineMakefile {
    croak "Inline::MakeMaker::WriteMakefile needs even number of args\n" 
      if @_ % 2;
    croak usage_postamble 
      unless MY::postamble('testing') eq 'roger';
    my %args = @_;
    croak "Inline::MakeMaker::WriteMakefile requires the NAME parameter\n"
      unless $args{NAME};
    croak <<END unless ($args{NAME} || $args{VERSION_NAME});
Inline::MakeMaker::WriteMakefile requires either the VERSION or
VERSION_FROM parameter.
END
    my $version = $args{VERSION} || 
      ExtUtils::MM_Unix->parse_version($args{VERSION_FROM})
	or croak "Can't determine version for $args{NAME}\n";
    croak <<END unless $version =~ /^\d\.\d\d$/;
Invalid version '$version' for $args{NAME}.
Must be of the form #.##. (For instance '1.23')
END
    push @versions, $version;

    my ($name, $object);
    if (defined $args{NAME}) {
	$name = $args{NAME};
	$object = (split(/::/, $name))[-1];
	push @modules, $name;
    }
    else {
	croak "Inline::MakeMaker::WriteMakefile requires a NAME parameter";
    }

    # Provide a convenience rule to clean up Inline's messes
    $args{clean} = { FILES => "_Inline $object.inl" } 
    unless defined $args{clean};
    # Add Inline to the dependencies
    $args{PREREQ_PM}{Inline} = '0.41' unless defined $args{PREREQ_PM}{Inline};

    &ExtUtils::MakeMaker::WriteMakefile(%args);
}

###############################################################################
# Inline utilities - Stubs for future development.
###############################################################################
my $i;
sub utils {
    print "->@_<-\n";
    require Inline;
    $i = bless {}, 'Inline';
    shift if $_[0] eq 'Inline';
    my $util = shift;
    no strict 'refs';
    goto &{uc($util)};
}

sub INSTALL {
    print <<END;

The INSTALL command has not yet been implemented.
Stay tuned...

@_

END
    exit 0;
}

sub MAKEPPD {
    print <<END;

The MAKEPPD command has not yet been implemented.
Stay tuned...

@_

END
    exit 0;
}

sub MAKEDIST {
    print <<END;

The MAKEDIST command has not yet been implemented.
Stay tuned...

@_

END
    exit 0;
}

1;
