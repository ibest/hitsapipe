>replacenames.pl
#!/usr/bin/env perl 

############################################
#namesback.pl <maindirectory>
#
# Will change names for the short ten character
# IDs back to their original names as
# recorded in namereport.
############################################
  
use warnings;
use strict;

my $count = 0;
my $file = $ARGV[0];
my $names = $ARGV[1];

open( TREEFILE, "$maindir/8Fphylo/outfile" );
open( MATRIXFILE, "$maindir/8Fphylo/distances" );
open( FILE, $file );
open( NAMES, "$names" );

my %names = ();

while( <NAMES> )
{
  my @idname = (split /\t/);
  chomp( $idname[1] );
  $names{ $idname[0] } = $idname[1];
}

my %filenames = %names;
while( <FILE> )
{
  while( my( $key, $value ) = each( %filenames ) )
  {
    if( /$key/ )
    {
      s/$key/$value/g;
      delete $filenames{$key};
    }
  }

   print;
}

