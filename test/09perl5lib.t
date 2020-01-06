#!/usr/bin/env testml


*perl.derive-minus-i == *minus-i-paths


=== TEST 1 - No settings
--- perl
--- minus-i-paths


=== TEST 2 - @INC added to with real dirs as non-existing filtered out
--- perl
push @INC, qw(doc eg);

--- minus-i-paths
doc
eg
