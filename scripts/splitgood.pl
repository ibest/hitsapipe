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
