package Inline::C::charity;
$VERSION = '0.44';
use strict;
use Regexp::Common;

sub new { bless {}, $_[0] }

# Derived from Inline::C::grammar.pm version 0.30 (Inline 0.43)
sub code {
    my($self,$code) = @_;
    
    # The order of these _does_ matter.
    $code =~ s/$RE{comment}{C}/ /go;
    $code =~ s/$RE{comment}{'C++'}/ /go;
    $code =~ s/^\#.*(\\\n.*)*//mgo;
    $code =~ s/$RE{quoted}/\"\"/go;
    $code =~ s/$RE{balanced}{-parens=>'{}'}/{ }/go;
    
    $self->{_the_code_most_recently_parsed} = $code;

    my $as_typemap = sub {
        my($type) = @_;

        # Remove "extern".
        # But keep "static", "inline", "typedef", etc,
        #  to cause typemap misses.
        $type =~ s/\bextern\b//g;

        # The only whitespace is single spaces,
        # with none leading or trailing.
        $type =~ s/\s+/ /g;
        $type =~ s/^\s//; $type =~ s/\s$//;

        # Adjacent "derivative characters" are not sparated by whitespace,
        # but _are_ sparated from the adjoning text.
        # [ Is really only * (and not ()[]) needed??? ]
        $type =~ s/\*\s\*/\*\*/g;
        $type =~ s/(?<=[^ \*])\*/ \*/g;

        return $type;
    };

    my $re_plausible_place_to_begin_a_declaration = qr {
        (?m: ^ )
    }xo;

    my $re_type_spec = qr {
        # modifier*
        #   "unsigned" is not included for backwards compatibility with
        #    Inline::C v0.43 pod documentation.  It should be added.
        #   Some keywords (eg,"long") can be "modifiers",
        #    but only if followed by a TYPE.
        ( (?: (?:extern|signed) \s+ )*
          (?: (?:long|short) \s+
              (?= (?:int|long|float|double)\b )
           )?
        ) \s*
        # TYPE
        (\w+) \s*
        # star*
        ( (?: \*\s* )* ) \s*
        }xo;

    my $re_identifier = qr {
        (\w+) \s*
        }xo;

    while($code =~ m{(
                      $re_plausible_place_to_begin_a_declaration
                      $re_type_spec
                      $re_identifier
                      $RE{balanced}{-parens=>'()'}{-keep}
                      \s* (\;|\{)
                      )}xgo)
    {
        my($modifiers,$type,$stars,
           $identifier,
           $ignore_copy_of_args_w_parens, $arguments,
           $what) = ($2,$3,$4, $5, $6,$7, $8);

        my $is_decl     = $what eq ';';
        my $function    = $identifier;
        my $return_type = &$as_typemap("$modifiers $type $stars");

        goto RESYNC if $is_decl && !$self->{data}{AUTOWRAP};
        goto RESYNC if $self->{data}{done}{$function};
        goto RESYNC if !defined
            $self->{data}{typeconv}{valid_rtypes}{$return_type};
        
        my(@arg_names,@arg_types);
        if($arguments !~ /^\s*$/) {
            my $dummy_name = 'arg1';

            foreach my $arg (split(',',$arguments)) {

                if(my($modifiers,$type,$stars, $identifier) =
                   $arg =~ /^\s*$re_type_spec(?:$re_identifier)?\s*$/o)
                {
                    my $arg_name = $identifier;
                    my $arg_type = &$as_typemap("$modifiers $type $stars");

                    if(!defined $arg_name) {
                        goto RESYNC if !$is_decl;
                        $arg_name = $dummy_name++;
                    }
                    goto RESYNC if !defined
                        $self->{data}{typeconv}{valid_types}{$arg_type};

                    push(@arg_names,$arg_name);
                    push(@arg_types,$arg_type);
                }
                elsif($arg =~ /^\s*\.\.\.\s*$/) {
                    push(@arg_names,'...');
                    push(@arg_types,'...');
                }
                else {
                    goto RESYNC;
                }
            }
        }


        # Commit.
        push @{$self->{data}{functions}}, $function;
        $self->{data}{function}{$function}{return_type}= $return_type; 
        $self->{data}{function}{$function}{arg_names} = [@arg_names];
        $self->{data}{function}{$function}{arg_types} = [@arg_types];
        $self->{data}{done}{$function} = 1;

        next;

      RESYNC:  # Punt the rest of the line, and continue.
        $code =~ /\G[^\n]*\n/gc;
    }
 
   return 1;  # We never fail.
}

1;
