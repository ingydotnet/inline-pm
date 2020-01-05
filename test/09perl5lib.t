#!/usr/bin/env testml

*perl.derive-minus-I == *perl5lib

=== TEST 1 - No settings
--- perl


--- perl5lib



=== TEST 2 - @INC added to with real dirs as non-existing filtered out
--- perl
push @INC, qw(doc eg);

--- perl5lib
doc
eg
