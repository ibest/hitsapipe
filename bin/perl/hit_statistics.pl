#!/usr/bin/env perl 

# USAGE: hit_statistics.pl <IN> <OUT>
# 
# Takes in an output spreadsheet and figures out how many
# sequences are labelled a particular species
#
  
use warnings;
use strict;

# get the input and output files
my $input_file = shift( @ARGV );
my $output_file = shift( @ARGV );

open( INFILE, "$input_file" ) || die "Could not open $input_file for reading!";

my %counts;
my %descriptions;

while( my $line = <INFILE> )
{
	my @fields = split( "\t", $line );
	my $name = $fields[2];
	my $description = $fields[3];
	
	next if( !$name );
	
	if( ! defined( $counts{$name} ))
	{
		$counts{$name} = 1;
		$descriptions{$name} = $description;
	}
	else
	{
		$counts{$name}++;
	}
}

close( INFILE );

open( OUT, ">$output_file" ) || die "Could not open $output_file for writing!";

print OUT "Hit sequence\tHit count\tHit description\n";

while( my ($name, $count) = each (%counts) ) 
{
	print OUT "$name\t$count\t$descriptions{$name}\n";
}

close( OUT );
