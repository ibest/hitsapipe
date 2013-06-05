#!/bin/bash
#####
# Requires:
#	PERL_DIR: 			Perl directory.
#	BLAST_DIR: 			Base blast directory.
#	BLAST_OUTPUT_DIR: 	The directory where the completed blasts were placed.
#	FINAL_OUTPUT_DIR: 	Final output direction (inside results)
#	NUMSEQS:
#####

# Get the number of blasts returned
NUMBLASTS=`find  ${BLAST_OUTPUT_DIR} -name "*.blastn" | wc -l`

# Make sure there are blasts and if there were, 

if [ ${NUMBLASTS} == 0 ]
then
  echo "ERROR: No blasts were found! Exiting."
  exit 1
elif [ ${NUMBLASTS} != $numseqs ]
then
  #check and see which ones might be missing
  echo "Number of blasts doesn't equal number of good sequences"
  echo "Checking for missing blasts"
  $scriptdir/blastcheck.bash $maindir
fi

#all the individual blasts into one file
echo "Concatenating the blast file"
#cat $maindir/blast/blasts/*.blastn > $maindir/blast/blastout5
#rm -f $maindir/blast/blastout5
find ${BLAST_OUTPUT_DIR} -maxdepth 1 -name "*.blastn" -print0 | xargs -i -0 cat {} >> ${BLAST_DIR}/blastout5

#move all blasts to their own folder
#echo "Moving blasts to proper folder"
#mkdir $maindir/blast/blasts
#mv *.blastn blasts



#makes two spreadsheets of the blast results --
#output5.xls has all the blasthits for all the sequences
#output1.xls has top hits for each only
echo "Parsing blast results"
${PERL_DIR}/blastparser.pl ${BLAST_DIR}/blastout5 > ${FINAL_OUTPUT_DIR}/output5.xls
#cd $maindir/8Fphylo
${PERL_DIR}/blastcull.pl < ${FINAL_OUTPUT_DIR}/output5.xls > ${FINAL_OUTPUT_DIR}/output1.xls