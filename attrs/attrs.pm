package Foo;
use YAML;
sub import { 
    my ($class, $arg) = @_;
    if ($arg eq 'attributes') {
        eval {
            use Attribute::Handlers();
            sub inline : ATTR(CODE) {
                use YAML;
                local $YAML::UseCode = 1;
                print Dump \@_;
            }
        };
        die "You need Attribute::Handlers:\n$@" if $@;
        my $caller = caller;
        push @{$caller . "::ISA"}, $class;
    }
}

1;
