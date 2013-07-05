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

####################################
#
#
####################################
  
use warnings;
use strict;

#finds the SEQ ID of the name given
sub findseq {

  my $outputdir = $_[0];
  my $name = $_[1];
  open( REPORT, "$outputdir/namereport" ) or die "findseq couldn't open: $!";
  
  while( <REPORT> )
  {
    my @line;

    if( /$name/ )
    {
      @line = split;
      return $line[0];
    }

  }

  print("WARNING!  COULD NOT FIND $name IN $outputdir/namereport\n" );
  return "";
}

#finds the species name given the SEQ ID
sub findspec {
   
  my $outputdir = $_[0];
  my $seq = $_[1];
  open( REPORT, "$outputdir/namereport" ) or die "findspec couldn't open: $!";

  while( <REPORT> )
  {
    my @line;

    if( /$seq/ )
    { 
      @line = split;
      return $line[1];
    }

  }
  
  print("WARNING!  COULD NOT FIND $seq IN $outputdir/namereport\n" );
  return "";
}

#returns the SEQ ID on a given line number for the distances file
sub seqnum{
  my $outputdir = $_[0];
  my $num = $_[1];
  open( DISTANCES, "$outputdir/distances" ) or die "seqnum couldn't open: $!";
  
  my $numSeq = 0;

  while( <DISTANCES> )
  {
    if( /(SEQ[0-9]{7})/ )
    {
      $numSeq++;
      if( $numSeq == $num )
      {
        my $name = findspec( $outputdir, $1 );
        return $name;
      }
    }
  }

  print("WARNING!  Could not find sequence $num in $outputdir/distances\n" );
  return "";
}

#returns the line number in a distances file for the given SEQ ID
sub numseq{

  my $outputdir = $_[0];
  my $seq = $_[1];
  open( DISTANCES, "$outputdir/distances" ) or die "numseq couldn't open: $!";

  my $seqID = findseq( $outputdir, $seq );
  my $numSeq = 0;

  while( <DISTANCES> )
  {
    if( /(SEQ[0-9]{7})/ )
    {
      $numSeq++;

      if( $seqID =~ /$1/ )
      {
        return $numSeq;
      }
    }
  }
  
  print("WARNING!  Could not find sequence $seq in $outputdir/distances\n" );

  return -1;
}

1;


