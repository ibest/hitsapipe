#!/usr/bin/env perl 

######
# This program counts the number of Ns in a sequence and cuts 
# the sequence at X% Ns -- percentage specified.  
# If length is Greater than the min length, returns the truncated sequence 
#
# Usage: countN2.pl percentage primer3 primer5 < filename > RESULTS
########

use warnings;
use strict;
#This is our new record indicator
$/ = "\>";

#percent of N's before the sequence is declared not good
my $percent = shift(@ARGV);
#Primer on the 3' end
my $Primer3 = shift(@ARGV);
#Primer on the 5' end
my $Primer5 = shift(@ARGV);
#Minimum length needed for a sequence to be accepted
my $minlength = shift(@ARGV);

while (<STDIN>) {
  chomp;
  next if( ! $_ );
  
	my $cnt=0;
	my $Ns=0;

  #unwrap sequence
	my $unwrapped = &fasta_unwrap();
  #split the name and sequence
  my ($name, $seq) =split /\t/, $unwrapped;
  #reverse the sequence
	my $rseq = reverse($seq);
  #take the primers out of the vector
	my ($justseq1, $vector1) = split /$Primer3/, $rseq;
	my ($justseq, $vector2) = split /$Primer5/, $justseq1;
  
  #go to the next record if the length is under the min length
  next if (length($rseq) < $minlength && $_);
	
  #get the char array of the sequence
  my @lseq = split //, $justseq;
  
 	my $newseq = undef;
	while ($cnt < 200) {
		my $nt = pop @lseq;
    $cnt++;
    next if( !$nt );
		if ($nt eq 'N') {
	     		$Ns++;
		}
		$newseq .= $nt;
	}

	next if ($Ns/200 > $percent);
	while ($cnt < length($seq) && $Ns/$cnt < $percent) {
		my $nt = pop @lseq;
    $cnt++;
    next if( !$nt );
		if ($nt eq 'N') {
	     		$Ns++;	
		}
		$newseq .= $nt;
	}
  
  print "\>$name\n$newseq\n"  if length($newseq) >= $minlength;
}

#unwraps a sequence into "NAME\tSEQUENCE"
sub fasta_unwrap {
  chomp;
  s/\n/\t/;
  s/\n//g;
  return "$_\n" if $_;
}
