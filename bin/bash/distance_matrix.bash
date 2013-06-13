#!/bin/bash
#####
# Requires:
#	DNADIST_SCRIPT
#	CLUSTAL_OUTPUT_DIR
#	DISTANCES_FILE
#	PHYLIP_IN_FILE
#####

# Use dnadist to create the distance matrix.
# Then, move the file it creates where we want it to be
# Then, rename the IN_FILE so that the next script doesn't have
# any issues.

cd ${CLUSTAL_OUTPUT_DIR}
echo "Making the distance matrix:"
dnadist < {DNADIST_SCRIPT}
mv outfile ${DISTANCES_FILE}
mv {PHYLIP_IN_FILE} {PHYLIP_IN_FILE}.dnadist