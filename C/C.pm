package Inline::C;

use strict;
require Inline;
require Inline::C::grammar;
use Config;
use Data::Dumper;
use Carp;
use Cwd qw(cwd abs_path);

$Inline::C::VERSION = '0.43';
@Inline::C::ISA = qw(Inline);

#==============================================================================
# Register this module as an Inline language support module
#==============================================================================
sub register {
    return {
	    language => 'C',
	    aliases => ['c'],
	    type => 'compiled',
	    suffix => $Config{dlext},
	   };
}

#==============================================================================
# Validate the C config options
#==============================================================================
sub usage_validate {
    my $key = shift;
    return <<END;
The value of config option '$key' must be a string or an array ref

END
}

sub validate {
    my $o = shift;

    $o->{ILSM} ||= {};
    $o->{ILSM}{XS} ||= {};
    $o->{ILSM}{MAKEFILE} ||= {};
    if (not $o->UNTAINT) {
	require FindBin;
	$o->{ILSM}{MAKEFILE}{INC} = "-I$FindBin::Bin";
    }
    $o->{ILSM}{AUTOWRAP} = 0 if not defined $o->{ILSM}{AUTOWRAP};
    $o->{ILSM}{XSMODE} = 0 if not defined $o->{ILSM}{XSMODE};
    $o->{ILSM}{AUTO_INCLUDE} ||= <<END;
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "INLINE.h"
END
    $o->{ILSM}{FILTERS} ||= [];
    $o->{STRUCT} ||= {
		      '.macros' => '',
		      '.xs' => '',
		      '.any' => 0, 
		      '.all' => 0,
		     };

    while (@_) {
	my ($key, $value) = (shift, shift);
	if ($key eq 'MAKE' or
	    $key eq 'AUTOWRAP' or
	    $key eq 'XSMODE'
	   ) {
	    $o->{ILSM}{$key} = $value;
	    next;
	}
	if ($key eq 'CC' or
	    $key eq 'LD') {
	    $o->{ILSM}{MAKEFILE}{$key} = $value;
	    next;
	}
	if ($key eq 'LIBS') {
	    $o->add_list($o->{ILSM}{MAKEFILE}, $key, $value, []);
	    next;
	}
	if ($key eq 'INC' or
	    $key eq 'MYEXTLIB' or
	    $key eq 'OPTIMIZE' or
	    $key eq 'CCFLAGS' or
	    $key eq 'LDDLFLAGS') {
	    $o->add_string($o->{ILSM}{MAKEFILE}, $key, $value, '');
	    next;
	}
	if ($key eq 'TYPEMAPS') {
	    croak "TYPEMAPS file '$value' not found"
	      unless -f $value;
	    my ($path, $file) = ($value =~ m|^(.*)[/\\](.*)$|) ?
	      ($1, $2) : ('.', $value);
	    $value = abs_path($path) . '/' . $file;
	    $o->add_list($o->{ILSM}{MAKEFILE}, $key, $value, []);
	    next;
	}
	if ($key eq 'AUTO_INCLUDE') {
	    $o->add_text($o->{ILSM}, $key, $value, '');
	    next;
	}
	if ($key eq 'BOOT') {
	    $o->add_text($o->{ILSM}{XS}, $key, $value, '');
	    next;
	}
	if ($key eq 'PREFIX') {
	    croak "Invalid value for 'PREFIX' option"
	      unless ($value =~ /^\w*$/ and
		      $value !~ /\n/);
	    $o->{ILSM}{XS}{PREFIX} = $value;
	    next;
	}
	if ($key eq 'FILTERS') {
	    next if $value eq '1' or $value eq '0'; # ignore ENABLE, DISABLE
	    $value = [$value] unless ref($value) eq 'ARRAY';
	    my %filters;
	    for my $val (@$value) {
		if (ref($val) eq 'CODE') {
		    $o->add_list($o->{ILSM}, $key, $val, []);
	        }
		else {
		    eval { require Inline::Filters };
		    croak "'FILTERS' option requires Inline::Filters to be installed."
		      if $@;
		    %filters = Inline::Filters::get_filters($o->{API}{language})
		      unless keys %filters;
		    if (defined $filters{$val}) {
			my $filter = Inline::Filters->new($val, 
							  $filters{$val});
			$o->add_list($o->{ILSM}, $key, $filter, []);
		    }
		    else {
			croak "Invalid filter $val specified.";
		    }
		}
	    }
	    next;
	}
	if ($key eq 'STRUCTS') {
	    # A list of struct names
	    if (ref($value) eq 'ARRAY') {
		for my $val (@$value) {
		    croak "Invalid value for 'STRUCTS' option"
		      unless ($val =~ /^[_a-z][_0-9a-z]*$/i);
		    $o->{STRUCT}{$val}++;
		}
	    }
	    # Enable or disable
	    elsif ($value =~ /^\d+$/) {
		$o->{STRUCT}{'.any'} = $value;
	    }
	    # A single struct name
	    else {
		croak "Invalid value for 'STRUCTS' option"
		  unless ($value =~ /^[_a-z][_0-9a-z]*$/i);
		$o->{STRUCT}{$value}++;
	    }
	    eval { require Inline::Struct };
	    croak "'STRUCTS' option requires Inline::Struct to be installed."
	      if $@;
	    $o->{STRUCT}{'.any'} = 1;
	    next;
	}
	my $class = ref $o; # handles subclasses correctly.
	croak "'$key' is not a valid config option for $class\n";
    }
}

sub add_list {
    my $o = shift;
    my ($ref, $key, $value, $default) = @_;
    $value = [$value] unless ref $value eq 'ARRAY';
    for (@$value) {
	if (defined $_) {
	    push @{$ref->{$key}}, $_;
	}
	else {
	    $ref->{$key} = $default;
	}
    }
}

sub add_string {
    my $o = shift;
    my ($ref, $key, $value, $default) = @_;
    $value = [$value] unless ref $value;
    croak usage_validate($key) unless ref($value) eq 'ARRAY';
    for (@$value) {
	if (defined $_) {
	    $ref->{$key} .= ' ' . $_;
	}
	else {
	    $ref->{$key} = $default;
	}
    }
}

sub add_text {
    my $o = shift;
    my ($ref, $key, $value, $default) = @_;
    $value = [$value] unless ref $value;
    croak usage_validate($key) unless ref($value) eq 'ARRAY';
    for (@$value) {
	if (defined $_) {
	    chomp;
	    $ref->{$key} .= $_ . "\n";
	}
	else {
	    $ref->{$key} = $default;
	}
    }
}

#==============================================================================
# Parse and compile C code
#==============================================================================
sub build {
    my $o = shift;
    $o->parse;
    $o->write_XS;
    $o->write_Inline_headers;
    $o->write_Makefile_PL;
    $o->compile;
}

#==============================================================================
# Return a small report about the C code..
#==============================================================================
sub info {
    my $o = shift;
    return <<END if $o->{ILSM}{XSMODE};
No information is currently generated when using XSMODE.

END
    my $text = '';
    $o->parse unless $o->{ILSM}{parser};
    if (defined $o->{ILSM}{parser}{data}{functions}) {
	$text .= "The following Inline $o->{API}{language} function(s) have been successfully bound to Perl:\n";
	my $parser = $o->{ILSM}{parser};
	my $data = $parser->{data};
	for my $function (sort @{$data->{functions}}) {
	    my $return_type = $data->{function}{$function}{return_type};
	    my @arg_names = @{$data->{function}{$function}{arg_names}};
	    my @arg_types = @{$data->{function}{$function}{arg_types}};
	    my @args = map {$_ . ' ' . shift @arg_names} @arg_types;
	    $text .= "\t$return_type $function(" . join(', ', @args) . ")\n";
	}
    }
    else {
	$text .= "No $o->{API}{language} functions have been successfully bound to Perl.\n\n";
    }
    $text .= Inline::Struct::info($o) if $o->{STRUCT}{'.any'};
    return $text;
}

sub config {
    my $o = shift;
}

#==============================================================================
# Parse the function definition information out of the C code
#==============================================================================
sub parse {
    my $o = shift;
    return if $o->{ILSM}{parser};
    $o->get_maps;
    $o->get_types;
    $o->{ILSM}{code} = $o->filter(@{$o->{ILSM}{FILTERS}});
    return if $o->{ILSM}{XSMODE};

    my $hack = sub { # Appease -w using Inline::Files
	print Parse::RecDescent::IN '';
        print Parse::RecDescent::IN '';
	print Parse::RecDescent::TRACE_FILE '';
        print Parse::RecDescent::TRACE_FILE '';
    };
    my $parser = $o->{ILSM}{parser} = $o->get_parser;

    Inline::Struct::parse($o) if $o->{STRUCT}{'.any'};
    $parser->code($o->{ILSM}{code})
      or croak "Bad $o->{API}{language} code passed to Inline at @{[caller(2)]}\n";
}

# Create and initialize a parser
sub get_parser {
    my $o = shift;
    my $grammar = Inline::C::grammar::grammar()
      or croak "Can't find C grammar\n";
    $::RD_HINT++;
    require Parse::RecDescent;
    my $parser = Parse::RecDescent->new($grammar);
    $parser->{data}{typeconv} = $o->{ILSM}{typeconv};
    $parser->{data}{AUTOWRAP} = $o->{ILSM}{AUTOWRAP};
    return $parser;
}

#==============================================================================
# Gather the path names of all applicable typemap files.
#==============================================================================
sub get_maps {
    my $o = shift;

    my $typemap = '';
    $typemap = "$Config::Config{installprivlib}/ExtUtils/typemap"
      if -f "$Config::Config{installprivlib}/ExtUtils/typemap";
    $typemap = "$Config::Config{privlibexp}/ExtUtils/typemap"
      if (not $typemap and -f "$Config::Config{privlibexp}/ExtUtils/typemap");
    warn "Can't find the default system typemap file"
      if (not $typemap and $^W);

    unshift(@{$o->{ILSM}{MAKEFILE}{TYPEMAPS}}, $typemap) if $typemap;

    if (not $o->UNTAINT) {
	require FindBin;
	if (-f "$FindBin::Bin/typemap") {
	    push @{$o->{ILSM}{MAKEFILE}{TYPEMAPS}}, "$FindBin::Bin/typemap";
	}
    }
}

#==============================================================================
# This routine parses XS typemap files to get a list of valid types to create
# bindings to. This code is mostly hacked out of Larry Wall's xsubpp program.
#==============================================================================
sub get_types {
    my (%type_kind, %proto_letter, %input_expr, %output_expr);
    my $o = shift;
    croak "No typemaps specified for Inline C code"
      unless @{$o->{ILSM}{MAKEFILE}{TYPEMAPS}};
    
    my $proto_re = "[" . quotemeta('\$%&*@;') . "]";
    foreach my $typemap (@{$o->{ILSM}{MAKEFILE}{TYPEMAPS}}) {
	next unless -e $typemap;
	# skip directories, binary files etc.
	warn("Warning: ignoring non-text typemap file '$typemap'\n"), next 
	  unless -T $typemap;
	open(TYPEMAP, $typemap) 
	  or warn ("Warning: could not open typemap file '$typemap': $!\n"), next;
	my $mode = 'Typemap';
	my $junk = "";
	my $current = \$junk;
	while (<TYPEMAP>) {
	    next if /^\s*\#/;
	    my $line_no = $. + 1; 
	    if (/^INPUT\s*$/)   {$mode = 'Input';   $current = \$junk;  next}
	    if (/^OUTPUT\s*$/)  {$mode = 'Output';  $current = \$junk;  next}
	    if (/^TYPEMAP\s*$/) {$mode = 'Typemap'; $current = \$junk;  next}
	    if ($mode eq 'Typemap') {
		chomp;
		my $line = $_;
		TrimWhitespace($_);
		# skip blank lines and comment lines
		next if /^$/ or /^\#/;
		my ($type,$kind, $proto) = 
		  /^\s*(.*?\S)\s+(\S+)\s*($proto_re*)\s*$/ or
		    warn("Warning: File '$typemap' Line $. '$line' TYPEMAP entry needs 2 or 3 columns\n"), next;
		$type = TidyType($type);
		$type_kind{$type} = $kind;
		# prototype defaults to '$'
		$proto = "\$" unless $proto;
		warn("Warning: File '$typemap' Line $. '$line' Invalid prototype '$proto'\n") 
		  unless ValidProtoString($proto);
		$proto_letter{$type} = C_string($proto);
	    }
	    elsif (/^\s/) {
		$$current .= $_;
	    }
	    elsif ($mode eq 'Input') {
		s/\s+$//;
		$input_expr{$_} = '';
		$current = \$input_expr{$_};
	    }
	    else {
		s/\s+$//;
		$output_expr{$_} = '';
		$current = \$output_expr{$_};
	    }
	}
	close(TYPEMAP);
    }

    my %valid_types = 
      map {($_, 1)}
    grep {defined $input_expr{$type_kind{$_}}}
    keys %type_kind;

    my %valid_rtypes = 
      map {($_, 1)}
    (grep {defined $output_expr{$type_kind{$_}}}
    keys %type_kind), 'void';

    $o->{ILSM}{typeconv}{type_kind} = \%type_kind;
    $o->{ILSM}{typeconv}{input_expr} = \%input_expr;
    $o->{ILSM}{typeconv}{output_expr} = \%output_expr;
    $o->{ILSM}{typeconv}{valid_types} = \%valid_types;
    $o->{ILSM}{typeconv}{valid_rtypes} = \%valid_rtypes;
}

sub ValidProtoString ($) {
    my $string = shift;
    my $proto_re = "[" . quotemeta('\$%&*@;') . "]";
    return ($string =~ /^$proto_re+$/) ? $string : 0;
}

sub TrimWhitespace {
    $_[0] =~ s/^\s+|\s+$//go;
}

sub TidyType {
    local $_ = shift;
    s|\s*(\*+)\s*|$1|g;
    s|(\*+)| $1 |g;
    s|\s+| |g;
    TrimWhitespace($_);
    $_;
}

sub C_string ($) {
    (my $string = shift) =~ s|\\|\\\\|g;
    $string;
}

#==============================================================================
# Write the XS code
#==============================================================================
sub write_XS {
    my $o = shift;
    my $modfname = $o->{API}{modfname};
    my $module = $o->{API}{module};
    $o->mkpath($o->{API}{build_dir});
    open XS, "> $o->{API}{build_dir}/$modfname.xs"
      or croak $!;
    if ($o->{ILSM}{XSMODE}) {
	warn <<END if $^W and  $o->{ILSM}{code} !~ /MODULE\s*=\s*$module\b/;
While using Inline XSMODE, your XS code does not have a line with

  MODULE = $module

You should use the Inline NAME config option, and it should match the
XS MODULE name.

END
	print XS $o->xs_code;
    }
    else {
	print XS $o->xs_generate;
    }
    close XS;
}

#==============================================================================
# Generate the XS glue code (piece together lots of snippets)
#==============================================================================
sub xs_generate {
    my $o = shift;
    return join '', ($o->xs_includes,
		     $o->xs_struct_macros,
		     $o->xs_code,
		     $o->xs_struct_code,
		     $o->xs_bindings,
		     $o->xs_boot,
		    );
}

sub xs_includes {
    my $o = shift;
    return $o->{ILSM}{AUTO_INCLUDE};
}

sub xs_struct_macros {
    my $o = shift;
    return $o->{STRUCT}{'.macros'};
}

sub xs_code {
    my $o = shift;
    return $o->{ILSM}{code};
}

sub xs_struct_code {
    my $o = shift;
    return $o->{STRUCT}{'.xs'};
}

sub xs_boot {
    my $o = shift;
    if (defined $o->{ILSM}{XS}{BOOT} and
	$o->{ILSM}{XS}{BOOT}) {
	return <<END;
BOOT:
$o->{ILSM}{XS}{BOOT}
END
    }
    return '';
}

sub xs_bindings {
    my $o = shift;
    my ($pkg, $module) = @{$o->{API}}{qw(pkg module)};
    my $prefix = (($o->{ILSM}{XS}{PREFIX}) ?
		  "PREFIX = $o->{ILSM}{XS}{PREFIX}" :
		  '');
    my $XS = <<END;

MODULE = $module	PACKAGE = $pkg	$prefix

PROTOTYPES: DISABLE

END

    my $parser = $o->{ILSM}{parser};
    my $data = $parser->{data};

    warn("Warning. No Inline C functions bound to Perl\n" .
	 "Check your C function definition(s) for Inline compatibility\n\n")
      if ((not defined$data->{functions}) and ($^W));

    for my $function (@{$data->{functions}}) {
	my $return_type = $data->{function}->{$function}->{return_type};
	my @arg_names = @{$data->{function}->{$function}->{arg_names}};
	my @arg_types = @{$data->{function}->{$function}->{arg_types}};

	$XS .= join '', ("\n$return_type\n$function (", 
		  join(', ', @arg_names), ")\n");

	for my $arg_name (@arg_names) {
	    my $arg_type = shift @arg_types;
	    last if $arg_type eq '...';
	    $XS .= "\t$arg_type\t$arg_name\n";
	}

	my $listargs = '';
	$listargs = pop @arg_names if (@arg_names and 
				       $arg_names[-1] eq '...');
	my $arg_name_list = join(', ', @arg_names);

	if ($return_type eq 'void') {
	    $XS .= <<END;
	PREINIT:
	I32* temp;
	PPCODE:
	temp = PL_markstack_ptr++;
	$function($arg_name_list);
	if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
	  PL_markstack_ptr = temp;
	  XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
	return; /* assume stack size is correct */
END
	}
	elsif ($listargs) {
	    $XS .= <<END;
	PREINIT:
	I32* temp;
	CODE:
	temp = PL_markstack_ptr++;
	RETVAL = $function($arg_name_list);
	PL_markstack_ptr = temp;
	OUTPUT:
        RETVAL
END
	}
    }
    $XS .= "\n";
    return $XS;
}

#==============================================================================
# Generate the INLINE.h file.
#==============================================================================
sub write_Inline_headers {
    my $o = shift;

    open HEADER, "> $o->{API}{build_dir}/INLINE.h"
      or croak;

    print HEADER <<'END';
#define Inline_Stack_Vars	dXSARGS
#define Inline_Stack_Items      items
#define Inline_Stack_Item(x)	ST(x)
#define Inline_Stack_Reset      sp = mark
#define Inline_Stack_Push(x)	XPUSHs(x)
#define Inline_Stack_Done	PUTBACK
#define Inline_Stack_Return(x)	XSRETURN(x)
#define Inline_Stack_Void       XSRETURN(0)

#define INLINE_STACK_VARS	Inline_Stack_Vars
#define INLINE_STACK_ITEMS	Inline_Stack_Items
#define INLINE_STACK_ITEM(x)	Inline_Stack_Item(x)
#define INLINE_STACK_RESET	Inline_Stack_Reset
#define INLINE_STACK_PUSH(x)    Inline_Stack_Push(x)
#define INLINE_STACK_DONE	Inline_Stack_Done
#define INLINE_STACK_RETURN(x)	Inline_Stack_Return(x)
#define INLINE_STACK_VOID	Inline_Stack_Void

#define inline_stack_vars	Inline_Stack_Vars
#define inline_stack_items	Inline_Stack_Items
#define inline_stack_item(x)	Inline_Stack_Item(x)
#define inline_stack_reset	Inline_Stack_Reset
#define inline_stack_push(x)    Inline_Stack_Push(x)
#define inline_stack_done	Inline_Stack_Done
#define inline_stack_return(x)	Inline_Stack_Return(x)
#define inline_stack_void	Inline_Stack_Void
END

    close HEADER;
}

#==============================================================================
# Generate the Makefile.PL
#==============================================================================
sub write_Makefile_PL {
    my $o = shift;
    $o->{ILSM}{xsubppargs} = '';
    for (@{$o->{ILSM}{MAKEFILE}{TYPEMAPS}}) {
	$o->{ILSM}{xsubppargs} .= "-typemap $_ ";
    }

    my %options = (
		   VERSION => $o->{API}{version} || '0.00',
		   %{$o->{ILSM}{MAKEFILE}},
		   NAME => $o->{API}{module},
		  );
    
    open MF, "> $o->{API}{build_dir}/Makefile.PL"
      or croak;
    
    print MF <<END;
use ExtUtils::MakeMaker;
my %options = %\{       
END

    local $Data::Dumper::Terse = 1;
    local $Data::Dumper::Indent = 1;
    print MF Data::Dumper::Dumper(\ %options);

    print MF <<END;
\};
WriteMakefile(\%options);

# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }
END
    close MF;
}

#==============================================================================
# Run the build process.
#==============================================================================
sub compile {
    my ($o, $perl, $make, $cmd, $cwd);
    $o = shift;
    my ($module, $modpname, $modfname, $build_dir, $install_lib) = 
      @{$o->{API}}{qw(module modpname modfname build_dir install_lib)};

    -f ($perl = $Config::Config{perlpath})
      or croak "Can't locate your perl binary";
    $make = $o->{ILSM}{MAKE} || $Config::Config{make}
      or croak "Can't locate your make binary";
    $cwd = &cwd;
    ($cwd) = $cwd =~ /(.*)/ if $o->UNTAINT;
    for $cmd ("$perl Makefile.PL > out.Makefile_PL 2>&1",
	      \ &fix_make,   # Fix Makefile problems
	      "$make > out.make 2>&1",
	      "$make pure_install > out.make_install 2>&1",
	     ) {
	if (ref $cmd) {
	    $o->$cmd();
	}
	else {
	    ($cmd) = $cmd =~ /(.*)/ if $o->UNTAINT;
	    chdir $build_dir;
	    system($cmd) and do {
#		$o->error_copy;
		croak <<END;

A problem was encountered while attempting to compile and install your Inline
$o->{API}{language} code. The command that failed was:
  $cmd

The build directory was:
$build_dir

To debug the problem, cd to the build directory, and inspect the output files.

END
	    };
	    chdir $cwd;
	}
    }

    if ($o->{API}{cleanup}) {
	$o->rmpath($o->{API}{directory} . '/build/', $modpname);
	unlink "$install_lib/auto/$modpname/.packlist";
	unlink "$install_lib/auto/$modpname/$modfname.bs";
	unlink "$install_lib/auto/$modpname/$modfname.exp"; #MSWin32 VC++
	unlink "$install_lib/auto/$modpname/$modfname.lib"; #MSWin32 VC++
    }
}

#==============================================================================
# This routine fixes problems with the MakeMaker Makefile.
#==============================================================================
my %fixes = (
	     INSTALLSITEARCH => 'install_lib',
	     INSTALLDIRS => 'installdirs',
	     XSUBPPARGS => 'xsubppargs',
	     INSTALLSITELIB => 'install_lib',
	    );

sub fix_make {
    use strict;
    my (@lines, $fix);
    my $o = shift;
    
    $o->{ILSM}{install_lib} = $o->{API}{install_lib};
    $o->{ILSM}{installdirs} = 'site';
    
    open(MAKEFILE, "< $o->{API}{build_dir}/Makefile")
      or croak "Can't open Makefile for input: $!\n";
    @lines = <MAKEFILE>;
    close MAKEFILE;
    
    open(MAKEFILE, "> $o->{API}{build_dir}/Makefile")
      or croak "Can't open Makefile for output: $!\n";
    for (@lines) {
	if (/^(\w+)\s*=\s*\S+.*$/ and
	    $fix = $fixes{$1}
	   ) {
	    print MAKEFILE "$1 = $o->{ILSM}{$fix}\n"
	}
	else {
	    print MAKEFILE;
	}
    }
    close MAKEFILE;
}

1;

__END__
