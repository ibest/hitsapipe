#!/usr/bin/env perl 

# makeneighbor.pl $maindir $rootspecies $libfolder $requiredlib
# makes a "script" for neighbor given the root species

use warnings;
use strict;
use lib "$ARGV[3]";
require("$ARGV[4]");

my $outputdir = $ARGV[0];
my $neighborscript = $ARGV[1];
my $rootspecies = $ARGV[2];

open( NEIGHBOR, ">$neighborscript" ) or die "makeneighbor couldn't open: $!";

my $seqID = findseq( $outputdir, $rootspecies);
my $number = numseq( $outputdir, $seqID );

print "Number of $rootspecies in $outputdir/distances: $number for $seqID\n";

print NEIGHBOR "distances\n";
print NEIGHBOR "O\n";
print NEIGHBOR "$number\n";
print NEIGHBOR "Y\n";

close( NEIGHBOR );