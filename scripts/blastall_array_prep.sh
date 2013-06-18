#!/bin/bash
#####
# Requires:
#	ARRAY_OUTPUT_FILE: 			File that stores the number of jobs in the array.
#	BLAST_INPUT_FILE: 			File that has list of files to count.
#	BLAST_TEMP_DIR: 			Directory where good fasta files are.
#####
# Additional:
#	NUMFILES: 					Number of jobs in the array.
#	FILE: 						Used in renaming the fasta files for blastall.
#	ITER: 						Simple iterator for renaming files.
#####

if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###"
	echo -e "\tBLAST_TEMP_DIR: ${BLAST_TEMP_DIR}"
	echo -e "\tBLAST_INPUT_FILE: ${BLAST_INPUT_FILE}"
	echo -e "\tARRAY_OUTPUT_FILE: ${ARRAY_OUTPUT_FILE}"
	echo -e "### DEBUG OUTPUT END ###"
fi

# Find the number of sequences in the input file to create a counter for
# renaming everything.
# Move into the temp directory where the fasta files are for renaming
# purposes.

ITER=0

cd ${BLAST_TEMP_DIR}

for FILE in $(cat ${BLAST_INPUT_FILE})
do
	echo "mv "${FILE}" "${FILE}.${ITER}""
	mv "${FILE}" "${FILE}.${ITER}"
	((ITER++))
done

echo "${ITER}" > ${ARRAY_OUTPUT_FILE}