Inline->init() ;

use Inline Config =>
    DIRECTORY => $TestInlineSetup::DIR,
    _TESTING => 1;

use Inline Bogus => <<'EOB';

foo(){}

EOB

