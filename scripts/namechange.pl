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

