#!/usr/bin/env perl 

#######
# This program converts all of the sequence Ns in the clustalall.phy file to
# ? for Phylip.
#
# Usage: convert_clustal_to_phylip.pl < IN > OUT
########

use warnings;
use strict;

#my $line = <STDIN>;  # get rid of the first line with the number params
#print $line;

while (my $line = <STDIN>) 
{
  #if( length( $line ) <= 1 )
  #{
  #  print "\n";
  #  next;
  #}
  
  #my $seqstart = substr( $line, 0, 10 );
  #my $seqline = substr( $line, 11 );
  
  #$seqline =~ tr/N/?/;
  
  #print $seqstart . $seqline;
  
  $line =~ tr/N/?/;
  
  print $line;
}
