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

############################################
# namesback.pl <maindirectory>
#
# Will change names for the short ten character
# IDs back to their original names as
# recorded in namereport.
############################################
  
use warnings;
use strict;

my $count = 0;
my $outputdir = $ARGV[0];

open( NAMES, "$outputdir/namereport" );

my %names = ();

while( <NAMES> )
{
  my @idname = (split /\t/);
  chomp( $idname[1] );
  $names{ $idname[0] } = $idname[1];
  #print "$idname[0] = $idname[1]\n";
}

close( NAMES );

open( TREEFILE, "$outputdir/outtree" );
open( TREEFINAL, ">$outputdir/finaltree.txt" );

#replace the names in the outfile
my %treenames = %names;
while( <TREEFILE> )
{
  while( my( $key, $value ) = each( %treenames ) )
  {
    #print "LOOKING FOR: $key to replace $value";
    if( /$key/ )
    {
      #print "Replacing $key in tree with $value\n";
      s/$key/$value/g;
      delete $treenames{$key};
    }
  }

   print TREEFINAL;
}

close( TREEFILE );
close( TREEFINAL );

open( OUTFILE, "$outputdir/outfile");
open( OUTFILEFINAL, ">$outputdir/finaloutfile.txt");

while( <OUTFILE> )
{
  while( my( $key, $value ) = each( %names ) )
  {
    if( /$key/ )
    {
      s/$key/$value/g;
      delete $treenames{$key};
    }
  }
  
  print OUTFILEFINAL;
}

open( MATRIXFILE, "$outputdir/distances" );
open( MATRIXFINAL, ">$outputdir/finaldistances" ); 

#replace the names in the matrix file
while( <MATRIXFILE> )
{
  while( my( $key, $value ) = each( %names ) )
  {
    if( /$key/ )
    {
      s/$key/$value/g;
      delete $treenames{$key};
    }
  }
  
  print MATRIXFINAL;
}

close( MATRIXFINAL );
close( MATRIXFILE );
