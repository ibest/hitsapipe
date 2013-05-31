>makeneighbor.pl
#!/usr/bin/env perl 

# makeneighbor.pl $maindir $rootspecies $libfolder $requiredlib
# makes a "script" for neighbor given the root species

use warnings;
use strict;
use lib "$ARGV[2]";
require("$ARGV[3]");

my $maindir = $ARGV[0];
my $rootspecies = $ARGV[1];

open( NEIGHBOR, ">$maindir/8Fphylo/neighbor_script" );

my $seqID = findseq( $maindir, $rootspecies);
my $number = numseq( $maindir, $seqID );

print "Number of $rootspecies in $maindir/8Fphylo/distances: $number for $seqID\n";

print NEIGHBOR "distances\n";
print NEIGHBOR "O\n";
print NEIGHBOR "$number\n";
print NEIGHBOR "Y\n";




