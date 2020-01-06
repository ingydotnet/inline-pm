#!/usr/bin/env testml


*perl.derive-minus-i == *minus-i-paths
  :"Test Inline->derive_minus_I -- +"


=== TEST 1 - No settings
--- perl
--- minus-i-paths


=== TEST 2 - Add relative paths to @INC
--- perl
push @INC, qw(doc eg);

--- minus-i-paths
doc
eg
