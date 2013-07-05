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

# USAGE:  perl nameshort.pl < INPUT > OUTPUT
# 
# Changes FASTA names to a 10 ID marker
# Saves the originals as namereport
#

use warnings;  
use strict;

my $count = 0;

open( REPORT, ">namereport" );

while( <STDIN> )
{
  if( />/ )
  {
    my $index = rindex( $_, ">" );
    my $name = substr( $_, $index );
    $name =~ s/^\s+//;
    $name =~ s/\s+$//;
    $name =~ s/\.AB1//g;
    $name =~ s/\///g;
    $name =~ s/#/_/g;
    $name =~ s/;//g;
    $name =~ s/:/-/g;
    $name =~ s/\(//g;
    $name =~ s/\)//g;
    $name =~ s/uncultured /uc_/g;
    $name =~ s/\s+/_/g;
    $name =~ s/\'//g;

    $count += 1;
    my $length = length( $count );
    my $filler = "";

    for( my $i = 0; $i < 10 - $length - 3; $i++ )
    {
       $filler = $filler . "0";
    }

    my $id = "SEQ" . $filler . $count;

    print ">$id\n";
    
    my $cutoff = index( $name, ">" );
    my $finalname = substr( $name, $cutoff+1 );
    print REPORT "$id\t$finalname\n";
  } 
  else
  {
    print;
  }
}

