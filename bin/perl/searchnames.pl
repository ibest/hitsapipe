#!/usr/bin/env perl 

####################################
#
#
####################################
  
use warnings;
use strict;

#finds the SEQ ID of the name given
sub findseq {

  my $maindir = $_[0];
  my $name = $_[1];
  open( REPORT, "$maindir/8Fphylo/namereport" );
  
  while( <REPORT> )
  {
    my @line;

    if( /$name/ )
    {
      @line = split;
      return $line[0];
    }

  }

  print("WARNING!  COULD NOT FIND $name IN $maindir/8Fphylo/namereport\n" );
  return "";
}

#finds the species name given the SEQ ID
sub findspec {
   
  my $maindir = $_[0];
  my $seq = $_[1];
  open( REPORT, "$maindir/8Fphylo/namereport" );

  while( <REPORT> )
  {
    my @line;

    if( /$seq/ )
    { 
      @line = split;
      return $line[1];
    }

  }
  
  print("WARNING!  COULD NOT FIND $seq IN $maindir/8Fphylo/namereport\n" );
  return "";
}

#returns the SEQ ID on a given line number for the distances file
sub seqnum{
  my $maindir = $_[0];
  my $num = $_[1];
  open( DISTANCES, "$maindir/8Fphylo/distances" );
  
  my $numSeq = 0;

  while( <DISTANCES> )
  {
    if( /(SEQ[0-9]{7})/ )
    {
      $numSeq++;
      if( $numSeq == $num )
      {
        my $name = findspec( $maindir, $1 );
        return $name;
      }
    }
  }

  print("WARNING!  Could not find sequence $num in $maindir/8Fphylo/distances\n" );
  return "";
}

#returns the line number in a distances file for the given SEQ ID
sub numseq{

  my $maindir = $_[0];
  my $seq = $_[1];
  open( DISTANCES, "$maindir/8Fphylo/distances" );

  my $seqID = findseq( $maindir, $seq );
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
  
  print("WARNING!  Could not find sequence $seq in $maindir/8Fphylo/distances\n" );

  return -1;
}

1;


