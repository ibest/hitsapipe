>namesback.pl
#!/usr/bin/env perl

############################################
# namesback.pl <maindirectory>
#
# Will change names for the short ten character
# IDs back to their original names as
# recorded in namereport.
############################################
  
use warnings;
use strict;

my $count = 0;
my $maindir = $ARGV[0];

open( NAMES, "$maindir/8Fphylo/namereport" );

my %names = ();

while( <NAMES> )
{
  my @idname = (split /\t/);
  chomp( $idname[1] );
  $names{ $idname[0] } = $idname[1];
  #print "$idname[0] = $idname[1]\n";
}

close( NAMES );

open( TREEFILE, "$maindir/8Fphylo/outtree" );
open( TREEFINAL, ">$maindir/8Fphylo/finaltree.txt" );

#replace the names in the outfile
my %treenames = %names;
while( <TREEFILE> )
{
  while( my( $key, $value ) = each( %treenames ) )
  {
    #print "LOOKING FOR: $key to replace $value";
    if( /$key/ )
    {
      #print "Replacing $key in tree with $value\n";
      s/$key/$value/g;
      delete $treenames{$key};
    }
  }

   print TREEFINAL;
}

close( TREEFILE );
close( TREEFINAL );

open( OUTFILE, "$maindir/8Fphylo/outfile");
open( OUTFILEFINAL, ">$maindir/8Fphylo/finaloutfile.txt");

while( <OUTFILE> )
{
  while( my( $key, $value ) = each( %names ) )
  {
    if( /$key/ )
    {
      s/$key/$value/g;
      delete $treenames{$key};
    }
  }
  
  print OUTFILEFINAL;
}

open( MATRIXFILE, "$maindir/8Fphylo/distances" );
open( MATRIXFINAL, ">$maindir/8Fphylo/finaldistances" ); 

#replace the names in the matrix file
while( <MATRIXFILE> )
{
  while( my( $key, $value ) = each( %names ) )
  {
    if( /$key/ )
    {
      s/$key/$value/g;
      delete $treenames{$key};
    }
  }
  
  print MATRIXFINAL;
}

close( MATRIXFINAL );
close( MATRIXFILE );
