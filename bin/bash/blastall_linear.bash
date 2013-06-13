#!/bin/bash
#####
# Requires:
#	BLAST_TEMP_DIR: 			Directory where fasta files to be blasted are.
#	BLASTALL_OUTPUT_DIR: 		Directory to place the output files.
#	DATABASE: 					Database to blast against.
#	NHITS: 						
#	PBS_ARRAYID: 				Used to determine which file to blast
#####
# Additional:
#	FILE: 						The filename without ".PBS_ARRAYID" attached to it
#####


for FILE in 

blastall -p blastn -d ${DATABASE}  -b ${NHITS} -v ${NHITS} -i "${FILE}.${PBS_ARRAYID}" -S 1 -o ${BLAST_OUTOUT_DIR}/${FILE}.blastn