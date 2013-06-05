#!/bin/bash
#####
# Requires:
#	BLAST_TEMP_DIR: 			Directory where all of the good fasta files are
#	BLAST_INPUT_FILE: 			List of the sequences that blastall needs to call.
#	BLASTALL_OUTPUT_DIR: 		Directory to place the output files.
#	DATABASE: 					Database to blast against.
#	NHITS: 						
#####
# This file moves all the fasta files in the blast directory
# into a temporary directory.
# Then, it counts the number the number of sequences to blast
# from the blast input file.
# Given this same list and the fasta files recently moved, it
# appends a unique identifier to each fasta file so that it can
# be called by qsub.

# Until I can easily change $PBS_O_WORKDIR, I'll manually cd into the
# BLAST_TEMP_DIR
# Also, I could run all of these as nice and busy wait until they are all
# completed in the background (not doing this).

cd ${BLAST_TEMP_DIR}
for FILE in $(cat ${BLAST_INPUT_FILE})
do
	echo "DEBUG: Command: blastall -p blastn -d ${DATABASE}  -b ${NHITS} -v ${NHITS} -i "${FILE}" -S 1 -o "${BLASTALL_OUTPUT_DIR}/${FILE}.blastn""
	EXITCODE=$(blastall -p blastn -d ${DATABASE}  -b ${NHITS} -v ${NHITS} -i "${FILE}" -S 1 -o "${BLASTALL_OUTPUT_DIR}/${FILE}.blastn")$?
	
	if [ ${EXITCODE} != 0 ]
	then
		echo -e "\nERROR: Blastall could not complete."
		echo -e "\tblastall exit code: ${EXITCODE}"
		exit 1
	fi
done