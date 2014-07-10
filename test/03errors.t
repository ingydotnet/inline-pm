use File::Spec;
use lib (File::Spec->catdir(File::Spec->curdir(),'blib','lib'), File::Spec->curdir());
use strict;
use Test;
use diagnostics;
use Inline Config => DIRECTORY => '_Inline_test';

BEGIN {
    plan(tests => 3,
	 todo => [],
	 onfail => sub {},
	);
}

# test 1
# Bad first parameter
BEGIN {
    eval <<'END';
    use Inline 'Bogus' => 'code';
END
    ok($@ =~ /\QYou have specified 'Bogus' as an Inline programming language.

I currently only know about the following languages:/);
}

# test 2
# Bad shortcut
BEGIN {
    eval <<'END';
    use Inline 'force', 'hocum';
END
    ok($@ =~ /\Q${\ Inline::M48_usage_shortcuts('hocum')}/);
}

# test 3
# Bad config option
BEGIN {
    eval <<'END';
    require Inline::Foo;
    use Inline Foo => 'xxx' => ENABLE => 'BOGUM';
END
    ok($@ =~ Inline::Foo::usage_config('BOGUM'));
}
