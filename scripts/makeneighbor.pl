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

# makeneighbor.pl $maindir $rootspecies $libfolder $requiredlib
# makes a "script" for neighbor given the root species

use warnings;
use strict;
use lib "$ARGV[3]";
require("$ARGV[4]");

my $outputdir = $ARGV[0];
my $neighborscript = $ARGV[1];
my $rootspecies = $ARGV[2];

open( NEIGHBOR, ">$neighborscript" ) or die "makeneighbor couldn't open: $!";

my $seqID = findseq( $outputdir, $rootspecies);
my $number = numseq( $outputdir, $seqID );

print "Number of $rootspecies in $outputdir/distances: $number for $seqID\n";

print NEIGHBOR "distances\n";
print NEIGHBOR "O\n";
print NEIGHBOR "$number\n";
print NEIGHBOR "Y\n";

close( NEIGHBOR );