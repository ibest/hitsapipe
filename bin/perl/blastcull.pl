>blastcull.pl
#!/usr/bin/env perl 

#USAGE:  perl blastcull.pl < (INFILE) > (OUTFILE)
#FUNCTION: Will take BLAST search results (INFILE) and cull only
#          the first lines with uniqueness according to 
#          first field member, printing them to (OUTFILE)
                    
use warnings;
                                                                                                          
$id = "null";
while(<STDIN>)
{
  $nid = (split /\t/)[0];
  if( !($id eq $nid) )
  {
    print;
    $id = $nid;
  }
}
