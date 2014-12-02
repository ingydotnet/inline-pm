package Inline::MakeMaker;

use strict;
use base 'Exporter';
use ExtUtils::MakeMaker();
use Carp;

our @EXPORT = qw(WriteMakefile WriteInlineMakefile);
our $VERSION = '0.78';

sub WriteInlineMakefile {
    carp <<EOF;

======================== DEPRECATION ALERT ======================

WriteInlineMakefile was deprecated in 2002. This warning is from 2014.
WriteInlineMakefile will soon be removed. Please change this Makefile.PL
to use WriteMakefile instead.

========================== MESSAGE ENDS =========================

EOF
     goto &WriteMakefile;
}

sub WriteMakefile {
    my %args = @_;
    my $name = $args{NAME}
      or croak "Inline::MakeMaker::WriteMakefile requires the NAME parameter\n";
    my $version = '';

    croak <<END unless (defined $args{VERSION} or defined $args{VERSION_FROM});
Inline::MakeMaker::WriteMakefile requires either the VERSION or VERSION_FROM
parameter.
END
    if (defined $args{VERSION}) {
        $version = $args{VERSION};
    }
    else {
        $version = ExtUtils::MM_Unix->parse_version($args{VERSION_FROM})
          or croak "Can't determine version for $name\n";
    }
    croak <<END unless $version =~ /^\d\.\d\d$/;
Invalid version '$version' for $name.
Must be of the form '#.##'. (For instance '1.23')
END

    # Provide a convenience rule to clean up Inline's messes
    $args{clean} = { FILES => "_Inline *.inl " }
    unless defined $args{clean};

    # Add Inline to the dependencies
    $args{PREREQ_PM}{Inline} = '0.44' unless defined $args{PREREQ_PM}{Inline};

    my $mm = &ExtUtils::MakeMaker::WriteMakefile(%args);

    my (@objects, @obj_rules);

    if (@{$mm->{PMLIBDIRS}} && $mm->{PM}) {
        # Sort them longest first so we'll match subdirectories before their parents
        my @libdirs = sort { length($b) <=> length($a) } @{$mm->{PMLIBDIRS}};

        for my $path (keys %{$mm->{PM}}) {
            for my $lib (@libdirs) {
                if (index($path,$lib) == 0) {
                    my ($vol, $dirs, $file) = File::Spec->splitpath(substr($path, length($lib)+1));
                    my @dirs = File::Spec->splitdir($dirs);
                    pop @dirs unless length($dirs[$#dirs]);
                    next unless ($file =~ /.pm$/);
                    $file =~ s/\.[^.]+$//;

                    push @objects, join('::', @dirs, $file);
                    push @obj_rules, join('-', @dirs, "$file.inl");
                    last;
                }
                croak "Failed to find module path for '$path'";
            }
        }
    } else {
        # no modules found in PMLIBDIRS so assume we've just got $name to do
        @objects = $name;
        $name =~ s/::/-/g;
        @obj_rules = ("$name.inl");
    }

    if (@objects) {
        open MAKEFILE, '>> Makefile'
          or croak "Inline::MakeMaker::WriteMakefile can't append to Makefile:\n$!";

        print MAKEFILE <<MAKEFILE;
# Well, not quite. Inline::MakeMaker is adding this:

# --- MakeMaker inline section:

MAKEFILE
    for (0..$#objects) {
        print MAKEFILE <<MAKEFILE;
$obj_rules[$_]: \$(TO_INST_PM)
\t\$(PERL) -Mblib -MInline=NOISY,_INSTALL_ -M$objects[$_] -e"Inline::satisfy_makefile_dep({API => {modinlname => '$obj_rules[$_]', module => '$objects[$_]'}});" $version \$(INST_ARCHLIB)
MAKEFILE
    }

print MAKEFILE "\npure_all :: ",join(' ',@obj_rules),"\n";

print MAKEFILE <<MAKEFILE;

# The End is here.
MAKEFILE

        close MAKEFILE;
    }
}

1;
