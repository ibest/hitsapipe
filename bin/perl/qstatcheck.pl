#!/usr/bin/env perl 

#USAGE:  perl qstatcheck.pl < processlistfile
# 
# Keeps checking qstat for the number listed in
# process list file and returns when they are
# gone & thus completed.
  
use warnings;
use strict;
my @processes = <STDIN>;
my $pausetime = 5;
my $totaltime = 0;

foreach( @processes )
{
#  print;
  chomp;
}

while(1)
{
  sleep( $pausetime );
  $totaltime += $pausetime;

  my $exists = 0;
  my @qstat = `qstat -s prs`;

  CHECK: foreach( @qstat )
  {
    my $pid = (split /\s+/)[1];

    foreach( @processes )
    {
#      print "Testing PID $_ against $pid\n";
      if( $_ && $pid && $_ eq $pid )
      {
#        print "$pid found\n";
        $exists = 1;
        last CHECK;
      }
    }
  }

  if( $exists )
  {
    print "Not all processes are finished yet...waiting ($totaltime sec).\n";
  }
  else
  {
#   print "No IDs found, finished.\n";
    print "All processes finished.  Total time: $totaltime.\n";
    last;
  }
}
