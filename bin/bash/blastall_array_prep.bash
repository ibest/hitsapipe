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