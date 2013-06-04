#!/bin/bash
# Move all files listed inside the input file into a directory.
# These files will be renamed for the call to qsub.
ITER=0
for FILE in ${BLAST_INPUT_FILE}
do 
mv "${PBS_O_WORKDIR}/${FILE}" "${BLAST_FASTA_DIR}/${FILE}.${ITER}"
ITER=$((ITER+1))
done
