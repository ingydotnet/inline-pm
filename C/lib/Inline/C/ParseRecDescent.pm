package Inline::C::ParseRecDescent;
use strict;
use Carp;
 
sub register {
    {
     extends => [qw(C)],
     overrides => [qw(get_parser)],
    }
}

sub get_parser {
    my $o = shift;
    eval { require Parse::RecDescent };
    croak <<END if $@;
This innvocation of Inline requires the Parse::RecDescent module.
$@
END
    $main::RD_HINT++;
    Parse::RecDescent->new(grammar())
}

sub grammar {
    <<'END';

code:   part(s) 
        {
         return 1;
        }

part:   comment
      | function_definition
        {
         my $function = $item[1][0];
         $return = 1, last if $thisparser->{data}{done}{$function}++;
         push @{$thisparser->{data}{functions}}, $function;
         $thisparser->{data}{function}{$function}{return_type} = 
             $item[1][1];
         $thisparser->{data}{function}{$function}{arg_types} = 
             [map {ref $_ ? $_->[0] : '...'} @{$item[1][2]}];
         $thisparser->{data}{function}{$function}{arg_names} = 
             [map {ref $_ ? $_->[1] : '...'} @{$item[1][2]}];
        }
      | function_declaration
        {
         $return = 1, last unless $thisparser->{data}{AUTOWRAP};
         my $function = $item[1][0];
         $return = 1, last if $thisparser->{data}{done}{$function}++;
         my $dummy = 'arg1';
         push @{$thisparser->{data}{functions}}, $function;
         $thisparser->{data}{function}{$function}{return_type} = 
             $item[1][1];
         $thisparser->{data}{function}{$function}{arg_types} = 
             [map {ref $_ ? $_->[0] : '...'} @{$item[1][2]}];
         $thisparser->{data}{function}{$function}{arg_names} = 
             [map {ref $_ ? ($_->[1] || $dummy++) : '...'} @{$item[1][2]}];
        }
      | anything_else

comment:  
        m{\s* // [^\n]* \n }x
      | m{\s* /\* (?:[^*]+|\*(?!/))* \*/  ([ \t]*)? }x

function_definition:
        rtype IDENTIFIER '(' <leftop: arg ',' arg>(s?) ')' '{'
        {
         [@item[2,1], $item[4]]
        }

function_declaration:
        rtype IDENTIFIER '(' <leftop: arg_decl ',' arg_decl>(s?) ')' ';'
        {
         [@item[2,1], $item[4]]
        }

rtype:  modifier(s?) TYPE star(s?)
        {
         $return = $item[2];
         $return = join ' ',@{$item[1]},$return 
           if @{$item[1]} and $item[1][0] ne 'extern';
         $return .= join '',' ',@{$item[3]} if @{$item[3]};
         return undef unless (defined $thisparser->{data}{typeconv}
                                                   {valid_rtypes}{$return});
        }

arg:    type IDENTIFIER {[@item[1,2]]}
      | '...'

arg_decl: 
        type IDENTIFIER(s?) {[$item[1], $item[2][0] || '']}
      | '...'

type:   modifier(s?) TYPE star(s?)
        {
         $return = $item[2];
         $return = join ' ',@{$item[1]},$return if @{$item[1]};
         $return .= join '',' ',@{$item[3]} if @{$item[3]};
         return undef unless (defined $thisparser->{data}{typeconv}
                                                   {valid_types}{$return});
        }

modifier: 
        'unsigned' | 'long' | 'extern' | 'const'

star:   '*'

IDENTIFIER: 
        /\w+/

TYPE:   /\w+/

anything_else: 
        /.*/

END
}

my $hack = sub { # Appease -w using Inline::Files
    print Parse::RecDescent::IN '';
    print Parse::RecDescent::IN '';
    print Parse::RecDescent::TRACE_FILE '';
    print Parse::RecDescent::TRACE_FILE '';
};

1;
