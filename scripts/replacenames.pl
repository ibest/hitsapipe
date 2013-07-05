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
#namesback.pl <maindirectory>
#
# Will change names for the short ten character
# IDs back to their original names as
# recorded in namereport.
############################################
  
use warnings;
use strict;

my $count = 0;
my $file = $ARGV[0];
my $names = $ARGV[1];

open( TREEFILE, "$maindir/8Fphylo/outfile" );
open( MATRIXFILE, "$maindir/8Fphylo/distances" );
open( FILE, $file );
open( NAMES, "$names" );

my %names = ();

while( <NAMES> )
{
  my @idname = (split /\t/);
  chomp( $idname[1] );
  $names{ $idname[0] } = $idname[1];
}

my %filenames = %names;
while( <FILE> )
{
  while( my( $key, $value ) = each( %filenames ) )
  {
    if( /$key/ )
    {
      s/$key/$value/g;
      delete $filenames{$key};
    }
  }

   print;
}

