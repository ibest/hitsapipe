#!/usr/bin/env perl

###########################################
#  blastpicks.pl <blastfile> > RESULTS
#  prints out the name and length of the blast
#  hits from blastfile, prints to STDOUT
############################################

use warnings;
use strict;
use Bio::SearchIO;

my $in = new Bio::SearchIO(-format => 'blast', 
                           -file   => $ARGV[0]);
while( my $result = $in->next_result ) {
  while( my $hit = $result->next_hit ) {
    while( my $hsp = $hit->next_hsp ) {

      print 
      $hit->name,"\t",
      $hsp->length('total'),"\n";
    }
  }
}



