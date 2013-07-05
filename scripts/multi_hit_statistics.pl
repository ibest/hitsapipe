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

# USAGE: multi_hit_statistics.pl <DIRECTORY> <OUTFILE>
# 
# Reads in all the hit_statistic.xls spreadsheets and
# collates them into one report.

use warnings;
use strict;

# the directory containing pipeline runs
my $directory = shift( @ARGV );
# the output file to write the results to
my $output_file = shift( @ARGV );

# keeps track of hit counts for each subdirectory
my %counts;
# keeps track of the descriptions for each hit sequence
my %descriptions;
# keeps a list of all the subdirectories
my @dirs;

# create a list of all the subdirectories
opendir( DIR, "$directory" ) || die "Could not open directory $directory for reading!";

while( my $dir = readdir(DIR) )
{
	# only push on directory files, and no hidden directories
	push( @dirs, $dir ) if ( ! -d $dir && $dir !~ /^\./ );
}

close( DIR );

#sort them so they are in order
@dirs = sort( @dirs );

### Gather the counts

# for each directory, read in and collate the hit statistics
foreach my $dir ( @dirs )
{
	my $infile = "$directory/$dir/8Fphylo/hit_statistics.xls";
	
	if( ! open( INFILE, $infile ))
	{
		warn "Could not open file $infile for the sample directory $dir\n";
		next;
	}
	
	#remove the headers line
	my $headers = <INFILE>;
	
	while( my $line = <INFILE> )
	{
		chomp( $line );
		
		# get the fields of each line
		my @fields = split( "\t", $line );
		my $name = $fields[0];
		my $count = $fields[1];
		my $description = $fields[2];
		
		# this would indicate a blank line, skip it
		next if( !$name );
		
		# record the count for this hit in this run
		$counts{$name}{$dir} = $count;
		
		# get the description for a hit if we don't have it already
		if( ! defined( $descriptions{$name} ))
		{
			$descriptions{$name} = $description;
		}
	}
	
	close( INFILE );
}

### Write the output file

open( OUT, ">$output_file" ) || die "Could not open $output_file for writing!";

# Print the headers
print OUT "Hit sequence\tTotal hit count\tHit description\t" . join( "\t", @dirs ) . "\n";

# go through all the hit counts
foreach my $name (sort(keys(%counts)))
{	
	my $total = 0;
	my @values;
	
	foreach my $dir ( @dirs )
	{
		# if a count for this hit exists for a given sample section
		# add it to the total and push it onto our values list
		if( defined( $counts{$name}{$dir} ))
		{
			$total += $counts{$name}{$dir};
			push( @values, $counts{$name}{$dir} );
		}
		# othewise, push 0 on
		else
		{
			push( @values, 0 );
		}
	}
	
	# print out the spreadsheet line
	print OUT "$name\t$total\t$descriptions{$name}\t" . join( "\t", @values ) . "\n";
}

close( OUT );
