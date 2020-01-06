#!/usr/bin/env testml


derive-minus-i(*perl) == *minus-i-paths
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


=== TEST 3 - Non-existing paths are removed
--- perl
push @INC, qw(foo doc bar eg baz);

--- ^minus-i-paths
