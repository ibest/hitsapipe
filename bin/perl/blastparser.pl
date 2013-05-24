#!/usr/bin/env perl

use warnings;
use strict;
use Bio::SearchIO;

my $in = new Bio::SearchIO(-format => 'blast', 
                           -file   => $ARGV[0]);
while( my $result = $in->next_result ) {
  while( my $hit = $result->next_hit ) {
    while( my $hsp = $hit->next_hsp ) {

      print 
      $result->query_name,"\t",
      $result->query_length,"\t",
      $hit->name,"\t",
      $hit->description,"\t",
      $hsp->significance,"\t",
      $hsp->percent_identity,"\t",
      $hsp->start('query'),"\t",
      $hsp->end('query'),"\t",
      $hsp->length('total'),"\n" 
      if $hsp->length('total')>0;
    }
  }
}



