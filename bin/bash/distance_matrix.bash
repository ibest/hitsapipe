#!/bin/bash
#####
# Requires:
#	DNADIST_SCRIPT
#	OUTPUT_DIR
#	DISTANCES_FILE
#	IN_FILE
#####

# Use dnadist to create the distance matrix.
# Then, move the file it creates where we want it to be
# Then, rename the IN_FILE so that the next script doesn't have
# any issues.

cd ${OUTPUT_DIR}
echo "Making the distance matrix:"
dnadist < {DNADIST_SCRIPT}
mv outfile ${DISTANCES_FILE}
mv {IN_FILE} {IN_FILE}.dnadist