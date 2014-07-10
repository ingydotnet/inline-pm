Inline->init() ;

use Inline Config =>
    DIRECTORY => '_Inline_test',
    _TESTING => 1;

use Inline Bogus => <<'EOB';

foo(){}

EOB

