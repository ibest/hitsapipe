#!/bin/bash
#####
# Requires:
#	BLAST_TEMP_DIR: 	Directory where all of the good fasta files are
#	BLAST_INPUT_FILE: 	List of the sequences that blastall needs to call.
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

cd ${BLAST_TEMP_DIR}
NUMSEQS=$(wc -l ${BLAST_INPUT_FILE})
ITER=0
for FILE in $(cat ${BLAST_INPUT_FILE})
do
	$(mv ${FILE} ${FILE}.${ITER})
	ITER=((ITER + 1))
done