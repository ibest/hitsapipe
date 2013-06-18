#!/usr/bin/env perl 

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

