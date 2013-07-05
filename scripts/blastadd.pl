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

##########################
# blastadd.pl <lengthcutoff> < strandsfile > RESULTS
#
# Will take in a file with all the "strands" of name\tlength,
# add them up, then print the added lengths with their names to
# STDOUT
#
##########################

use warnings;
use strict;
my %hash;

my $lengthcutoff = $ARGV[0];

#read in the file, keep track of all names, add all lengths
#attributed to the same name
while(<STDIN>)
{
  my @line = (split /\t/);

  if( exists $hash{ $line[0] } )
  {
    $hash{ $line[0] } = $line[1] + $hash{ $line[0] };
  }
  else
  {
    $hash{ $line[0] } = $line[1];
  }
}

#delete all names that don't have lengths longer than the
#value given
while( (my $key, my $value) = each %hash )
{
   if( $value < $lengthcutoff )
   {
     delete $hash{$key};
   }
}

my @keyArray = keys( %hash );
my $iteration = 0;

#print out all names/lengths except the last
for( $iteration = 0; $iteration < @keyArray; $iteration++ )
{
   if( length( $keyArray[$iteration] ) > 0 )
   {
     my $name = $keyArray[$iteration];
     my $length = $hash{ $keyArray[$iteration] };
     chomp( $name );
     chomp( $length );
     print "$name\t$length\n";
   }
}

if( $keyArray[$iteration] )
{
  print "$keyArray[$iteration]\t$hash{ $keyArray[$iteration] }";
}
