#!/usr/bin/env perl 

# USAGE: namechange.pl <SUFFIX>
# 
# Changes the fasta or plain sequence names to the 
# name of the filename of all the filenames with the
# given suffix
#
  
use warnings;
use strict;

# get all files in the directory ending in the given suffix
my $suffix = $ARGV[0];
my @filenames = glob "*$suffix";

#go through each file and change the FASTA name
foreach my $filename ( @filenames ) 
{ 
  open( FILE, "+< $filename" );
  my @lineArray  = <FILE>;

	if( scalar(@lineArray) == 0 )
	{
		print "WARNING: $filename has no content!\n";
	}
	
  #if we already have a fasta name line
  if( $lineArray[0] =~ />/)
  {
    $lineArray[0] = ">$filename\n";
    
    seek( FILE, 0, 0 );
    print FILE @lineArray;
    truncate( FILE, tell(FILE) );
    close( FILE );
  }
  #if we don't have a fasta name line -- fixes malformed files, or plain
  #sequence files
  else
  {
    seek( FILE, 0, 0 );
    print FILE ">$filename\n";
    print FILE @lineArray;
    truncate( FILE, tell(FILE) );
    close( FILE );
  }
}

