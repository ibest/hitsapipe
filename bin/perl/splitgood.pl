#!/usr/bin/env perl 

#######
# This program splits up a fasta formatted file
# and splits it into seperate files according to the first
# word of the name.
#
# Usage: splitgood.pl < <FILE>
########

use warnings;
use strict;
$/ = "\>";
my $scripts = $ARGV[0];

while (<STDIN>) 
{
  my $input = $_;
  my $unwrapped = &fasta_unwrap($input);
  my($longname, $seq) = split /\t/, $unwrapped;

  if( ! $longname )
  {
    next;
  }

  my @nameparts = split / /, $longname;
  my $name = $nameparts[0];
  chomp $name;

  #print "TRYING TOP OPEN $name\n";
  open( FILE, ">$name" );
  #print "$name opened\n\n";
  print FILE ">$name\n$seq";
  close FILE;
}

unlink <*.temp>;

#unwraps a fasta formatted record into "NAME/tSEQUENCE"
sub fasta_unwrap {
  chomp;
  s/\n/\t/;
  s/\n//g;
  return "$_\n" if $_;
}

#trims all whitespace from the beginning and end of a name
sub trim
{
  foreach( @_ )
  {
    $_ =~ s/^\s+//;
    $_ =~ s/\s+$//;
  }
}
