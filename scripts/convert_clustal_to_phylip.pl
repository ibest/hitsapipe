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
# This program converts all of the sequence Ns in the clustalall.phy file to
# ? for Phylip.
#
# Usage: convert_clustal_to_phylip.pl < IN > OUT
########

use warnings;
use strict;

#my $line = <STDIN>;  # get rid of the first line with the number params
#print $line;

while (my $line = <STDIN>) 
{
  #if( length( $line ) <= 1 )
  #{
  #  print "\n";
  #  next;
  #}
  
  #my $seqstart = substr( $line, 0, 10 );
  #my $seqline = substr( $line, 11 );
  
  #$seqline =~ tr/N/?/;
  
  #print $seqstart . $seqline;
  
  $line =~ tr/N/?/;
  
  print $line;
}
