#!/bin/bash
#####
# Requires:
#	BLASTALL_OUTPUT_DIR: 	Directory with the blastall result files
#	BLAST_INPUT_FILE: 		List of the sequences that should have blast output
#	NUMSEQS_TEMP_FILE: 		Contains the number of sequences that should have been blasted
#####
# Additional:
#	NUMSEQS: 				Number of sequences that should have been blasted.
#	NUMBLASTS: 				Number of sequences actually blasted.
#####

if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###"
	echo -e "\tBLASTALL_OUTPUT_DIR: ${BLASTALL_OUTPUT_DIR}"
	echo -e "\tBLAST_INPUT_FILE: ${BLAST_INPUT_FILE}"
	echo -e "\tNUMSEQS_TEMP_FILE: ${NUMSEQS_TEMP_FILE}"
	echo -e "### DEBUG OUTPUT END ###"
fi

NUMSEQS=$(cat ${NUMSEQS_TEMP_FILE})
NUMBLASTS=$(find ${BLASTALL_OUTPUT_DIR} -name "*.blastn" | wc -l)

echo "Number of sequences: ${NUMSEQS}"
echo "Number of blasts: ${NUMBLASTS}"

echo "Checking to see that all blasts were found."
# preliminary check that we have all the needed blasts
if [ ${NUMBLASTS} == 0 ]
then
  echo "ERROR -- No blasts found!  Exiting."
  touch {ERROR_FILE}
  exit 1
elif [ ${NUMBLASTS} -ne ${NUMSEQS} ] # Could also have NUMBLASTS != NUMSEQS
then
  echo "Number of blasts doesn't equal number of good sequences"
  echo "Checking for missing blasts:"
  
  for FILE in `cat ${BLAST_INPUT_FILE}` 
  do
    if [ ! -e "${FILE}.blastn" ]
    then
      echo -e "\tWARNING!  WARNING!  ${FILE} does not have a BLAST output!"
    fi
  done
fi