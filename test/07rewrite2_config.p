Inline->init() ;

use Inline Config =>
    DIRECTORY => $TestInlineSetup::DIR,
    _TEsTING => 1;

use Inline Bogus => <<'EOB';

foo(){}

EOB

