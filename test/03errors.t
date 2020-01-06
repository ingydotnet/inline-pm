#!/usr/bin/env testml


*perl.eval-catch =~ *error-patterns


=== Bad first parameter
--- perl
use Inline Bogus => 'code';
--- error-patterns(@/)
You have specified 'Bogus' as an Inline programming language.
I currently only know about the following languages:


=== Bad shortcut
--- perl
use Inline 'force', 'hocum';
--- error-patterns(@/)
Invalid shortcut 'hocum' specified.
Valid shortcuts are:
VERSION, INFO, FORCE, NOCLEAN, CLEAN, UNTAINT, SAFE, UNSAFE,
GLOBAL, NOISY and REPORTBUG


=== Bad config option
--- perl
use Inline Foo => 'xxx' => ENABLE => 'BOgUM';
--- error-patterns(@/)
'BOGUM' is not a valid config option for Inline::Foo
