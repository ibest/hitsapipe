#!/bin/bash
#####
# Requires:
#	BLAST_TEMP_DIR: 			Directory where all of the good fasta files are
#	BLASTALL_OUTPUT_DIR: 		Directory to place the output files.
#	DATABASE: 					Database to blast against.
#	NHITS: 						
#####
# Additional:
#	TO_BLAST: 				The name of the file we are blasting
#	BLAST_OUTPUT_NAME: 		The output name of the file
#####

# Run find on the directory to find which file we are supposed to blast.
# Then get its basename without the array id appended to it for saving the
# output from blastall.

echo "BLAST_TEMP_DIR: 			${BLAST_TEMP_DIR}"
echo "BLASTALL_OUTPUT_DIR: 		${BLASTALL_OUTPUT_DIR}"
echo "DATABASE: 				${DATABASE}"
echo "NHITS: 					${NHITS}"

TO_BLAST=$(find ${BLAST_TEMP_DIR} -maxdepth 1 -name "*.${PBS_ARRAYID}")
BLAST_OUTPUT_NAME=$(basename ${TO_BLAST%.*})
BLAST_OUTPUT_NAME=$(echo "${BLAST_OUTPUT_NAME}.blastn")

echo "TO_BLAST: 				${TO_BLAST}"
echo "BLAST_OUTPUT_NAME: 		${BLAST_OUTPUT_NAME}"

echo "Blasting file ${TO_BLAST} against the database ${DATABASE}"
echo -e "\tStoring the output in ${BLASTALL_OUTPUT_DIR}/${BLAST_OUTPUT_NAME}"

EXITCODE=$(blastall -p blastn -d ${DATABASE}  -b ${NHITS} -v ${NHITS} -i "${TO_BLAST}" -S 1 -o "${BLASTALL_OUTPUT_DIR}/${BLAST_OUTPUT_NAME}")$?

if [ ${EXITCODE} != 0 ]
then
	echo -e "\nERROR: Blastall could not complete."
	echo -e "\tblastall exit code: ${EXITCODE}"
	exit ${EXITCODE}
fi

# Finally, change the name back of this file
echo "Blast successful. Removing PBS array file extension."
RENAME=$(echo "${TO_BLAST%.*}")
EXITCODE=$(mv ${TO_BLAST} ${RENAME})$?
exit ${EXITCODE}