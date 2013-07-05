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

###########################################
#  blastpicks.pl <blastfile> > RESULTS
#  prints out the name and length of the blast
#  hits from blastfile, prints to STDOUT
############################################

use warnings;
use strict;
use Bio::SearchIO;

my $in = new Bio::SearchIO(-format => 'blast', 
                           -file   => $ARGV[0]);
while( my $result = $in->next_result ) {
  while( my $hit = $result->next_hit ) {
    while( my $hsp = $hit->next_hsp ) {

      print 
      $hit->name,"\t",
      $hsp->length('total'),"\n";
    }
  }
}



