package Inline::MakeMaker;

my (undef, $bootstrap_code) = (<<__EOVIMTRICK__, <<'__EOCODE__');
__EOVIMTRICK__
package _bootstrap::makemaker;
*_bootstrap::makemaker::import = \&Inline::MakeMaker::import;
*_bootstrap::makemaker::VERSION = \$Inline::MakeMaker::VERSION;
package Inline::MakeMaker;
use strict;
use Carp;
use Config;
$Inline::MakeMaker::VERSION = '0.50';

my (@modules, @versions);

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

pure_all :: ensure_inline_installed $object.inl

ensure_inline_installed :
	\@\$(PERL) -Mblib -MFile::Copy \\
	-e 'eval "use Inline";' \\
	-e 'if (\$\$@) {' \\
	-e '    copy("_bootstrap/Inline.pm", "./blib/lib");' \\
	-e '    mkdir("./blib/lib/Inline");' \\
	-e '    mkdir("./blib/lib/Inline/C");' \\
	-e '    copy("_bootstrap/Inline/devel.pm", "./blib/lib/Inline/");' \\
	-e '    copy("_bootstrap/Inline/C.pm", "./blib/lib/Inline");' \\
	-e '    copy("_bootstrap/Inline/denter.pm", "./blib/lib/Inline/");' \\
	-e '    copy("_bootstrap/Inline/C/charity.pm", "./blib/lib/Inline/C");' \\
	-e '} elsif (\$\$Inline::VERSION lt '0.50') {' \\
	-e '    die "You need to install the latest Inline.pm or uninstall the current one\\n";' \\
	-e '}';

dist :
	tar xzf \$(DISTVNAME).tar\$(SUFFIX)
	\$(PERL) -pi -e 's/Inline::MakeMaker/_bootstrap::makemaker/' \\
	\$(DISTVNAME)/Makefile.PL
	find _bootstrap | cpio -dump \$(DISTVNAME)
	mkdir \$(DISTVNAME)/_bootstrap/Inline
	mkdir \$(DISTVNAME)/_bootstrap/Inline/C
	\$(PERL) -MInline -MFile::Copy \\
	-e 'copy(\$\$INC{"Inline.pm"}, "\$(DISTVNAME)/_bootstrap")'
	\$(PERL) -MFile::Copy \\
	-e 'require Inline::C;' \\
	-e 'copy(\$\$INC{"Inline/C.pm"}, "\$(DISTVNAME)/_bootstrap/Inline")'
	\$(PERL) -MFile::Copy \\
	-e 'require Inline::devel;' \\
	-e 'copy(\$\$INC{"Inline/devel.pm"}, "\$(DISTVNAME)/_bootstrap/Inline")'
	\$(PERL) -MFile::Copy \\
	-e 'require Inline::denter;' \\
	-e 'copy(\$\$INC{"Inline/denter.pm"}, "\$(DISTVNAME)/_bootstrap/Inline")'
	\$(PERL) -MFile::Copy \\
	-e 'require Inline::C::charity;' \\
	-e 'copy(\$\$INC{"Inline/C/charity.pm"}, "\$(DISTVNAME)/_bootstrap/Inline/C")'
	tar czf \$(DISTVNAME).tar\$(SUFFIX) \$(DISTVNAME)
	rm -fr \$(DISTVNAME)
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
    my $package = caller;
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
    croak <<END unless ($args{VERSION} || $args{VERSION_FROM});
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

    &ExtUtils::MakeMaker::WriteMakefile(%args);
    system q{perl -pi -e 's/^(dist\s*:)/$1:/' Makefile} and die;
}

1;
__EOCODE__

#==============================================================================
my $dir = '_bootstrap';
-d $dir or mkdir($dir) or die "Couldn't mkdir('$dir'): $!";
my $bootstrap_pm = "$dir/makemaker.pm";
open(BOOTSTRAP, ">$bootstrap_pm") or die "Couldn't open $bootstrap_pm: $!";
print BOOTSTRAP $bootstrap_code;
close(BOOTSTRAP);

require $bootstrap_pm;

1;
