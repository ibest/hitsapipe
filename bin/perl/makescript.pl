>makescript.pl
#!/usr/bin/env perl 

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
