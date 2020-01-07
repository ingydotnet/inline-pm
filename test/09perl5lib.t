#!/usr/bin/env testml


*perl.derive-minus-i(*paths) == *paths
  :"Test Inline->derive_minus_I -- +"


=== TEST 1 - No settings
--- perl
--- paths


=== TEST 2 - Add relative paths to @INC
--- perl
push @INC, qw(doc eg);

--- paths
doc
eg


=== TEST 3 - Non-existing paths are removed
--- perl
push @INC, qw(foo doc bar eg baz);

--- ^paths
