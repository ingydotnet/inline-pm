use ExtUtils::MakeMaker;

WriteMakefile(
	      NAME => 'Inline',
	      VERSION_FROM => 'Inline.pm',
	      PREREQ_PM => {
			    Data::Dumper => 2.09,
			    Digest::MD5 => 2.09,
			    Parse::RecDescent => 1.78,
			   },
	      clean => {FILES => '_Inline_test/ _Inline/ .Inline/'},
	     );
