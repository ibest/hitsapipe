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

echo "Debug start..."
echo -e "\tDNADIST_SCRIPT: ${DNADIST_SCRIPT}"
echo -e "\tDNADIST_SCRIPT: ${DISTANCES_FILE}"
echo -e "\tDNADIST_SCRIPT: ${PHYLIP_IN_FILE}"
echo "Debug end..."

cd ${CLUSTAL_OUTPUT_DIR}
echo "Making the distance matrix..."
dnadist < ${DNADIST_SCRIPT}
mv outfile ${DISTANCES_FILE}
mv "${PHYLIP_IN_FILE}" "${PHYLIP_IN_FILE}.dnadist"