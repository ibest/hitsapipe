#!/usr/bin/env perl 

###########################################
# findalign.pl < <alignmentfile> > <Startandend>
#
# Given a clustal alignment file, finds
# the start and end by finding where the last
# sequence starts and the first sequence ends
###########################################
  
use warnings;
use strict;

my $count = 0;
my %alignment = ();

while( <STDIN> )
{
  if( /SEQ[0-9]{7}\d*[-A-Z]*/ )
  {
    my @line = split " ";
    if( $alignment{ $line[0] } )
    {
      my $combine = join "", "$alignment{ $line[0] }" , "$line[1]"; 
      $alignment{ $line[0] } = $combine;
    }
    else
    {
      $alignment{ $line[0] } = $line[1];
    }
  }
}

#default nonsense values for start and end
my $start = 0;
my $end = 100000000;

while( my( $sequence, $alignment ) = each( %alignment ) )
{
  my $length = length( $alignment );
  my $i = 0;

  for(  $i = 0; $i < $length; $i++ )
  {
    if( substr( $alignment, $i, 1 ) ne "-" )
    {
       if( $i + 1 > $start ){ $start = $i + 1; } # print "NEW START $sequence: $start\n" }
       last;
    }
  }
 
  for( $i = 0; $i < $length; $i++ )
  {
    my $x = $length - $i - 2;
    my $char = substr( $alignment, $x, 1 );
    if( $char ne "-" )
    {
      if( $x + 1 < $end){ $end = $x + 1; } # print "NEW END $sequence: $end\n" }
      last;
    }
  }
}

print "START $start\n"; 
print "END $end\n";
