Inline->init() ;

use Inline Config =>
    DIRECTORY => '_Inline_07rewrite2_config',
    _TESTING => 1;

use Inline Bogus => <<'EOB';

foo(){}

EOB

