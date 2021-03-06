#!/usr/bin/env perl 

# ***** BEGIN LICENSE BLOCK *****
# Version: MPL 1.1
#
# The contents of this file are subject to the Mozilla Public License Version
# 1.1 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
#
# Contributor(s):
#
# ***** END LICENSE BLOCK *****

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
