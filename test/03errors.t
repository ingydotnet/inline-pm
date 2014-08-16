use strict; use warnings;
use lib -e 't' ? 't' : 'test';
use TestInlineSetup;
use Test::More tests => 3;
use Inline Config => DIRECTORY => $TestInlineSetup::DIR;

eval "use Inline Bogus => 'code';";
like($@, qr/\QYou have specified 'Bogus' as an Inline programming language.

I currently only know about the following languages:/, 'Bad first parameter');

eval "use Inline 'force', 'hocum';";
like($@, qr/\Q${\ Inline::M48_usage_shortcuts('hocum')}/, 'Bad shortcut');

eval "use Inline Foo => 'xxx' => ENABLE => 'BOgUM';";
like($@, qr/${\ Inline::Foo::usage_config('BOGUM') }/, 'Bad config option');
