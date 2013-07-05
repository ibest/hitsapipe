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

# USAGE:  makescript.pl <directory> <filetowrite> <preferences file to use>
#
# Creates a script that will run the pipeline
#
  
use warnings;
use strict;
my $scripts = "/mnt/home/ajohnson/pipeline/scripts";
my $prefs = $ARGV[2];
my @filenames = glob "$ARGV[0]/*";
open( SCRIPT, ">$ARGV[1]" ) or die "Can't make script file!";

foreach( @filenames ) 
{ 
  if( -d "$_" )
  {
    print SCRIPT "$scripts/pipeline.bash $_ $prefs > $_\_RESULTS\n";
    print SCRIPT "echo \"$_ done\"\n";
    print SCRIPT "echo \"HITS: \"\n";
    print SCRIPT "cat $_/8Fphylo/hitnames\n\n";
    print SCRIPT "echo\n";
  }
}

close( SCRIPT );
chmod 0755, $ARGV[1];
