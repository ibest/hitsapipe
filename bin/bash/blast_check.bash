#!/bin/bash
#####
# Requires:
#	BLAST_OUTPUT_DIR
#	BLAST_INPUT_FILE
#	NUMSEQS
#####

NUMBLASTS=`find  ${BLAST_OUTPUT_DIR} -name "*.blastn" | wc -l`

# preliminary check that we have all the needed blasts
if [ ${NUMBLASTS} == 0 ]
then
  echo "ERROR -- No blasts found!  Exiting."
  exit 1
elif [ ${NUMBLASTS} != ${NUMSEQS} ]
then
  #check and see which ones might be missing
  echo "Number of blasts doesn't equal number of good sequences"
  echo "Checking for missing blasts"
  #$scriptdir/blastcheck.bash $maindir
  for FILE in `cat ${BLAST_INPUT_FILE}` 
  do

    if [ ! -e "${FILE}.blastn" ]
    then
      echo "WARNING!  WARNING!  $FILE does not have a BLAST output!"
    fi
  done
fi
