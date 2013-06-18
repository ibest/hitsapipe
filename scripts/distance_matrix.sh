#!/bin/bash
#####
# Requires:
#	DNADIST_SCRIPT
#	CLUSTAL_OUTPUT_DIR
#	DISTANCES_FILE
#	PHYLIP_IN_FILE
#####

if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###"
	echo -e "\tDNADIST_SCRIPT: ${DNADIST_SCRIPT}"
	echo -e "\tCLUSTAL_OUTPUT_DIR: ${CLUSTAL_OUTPUT_DIR}"
	echo -e "\tDISTANCES_FILE: ${DISTANCES_FILE}"
	echo -e "\tPHYLIP_IN_FILE: ${PHYLIP_IN_FILE}"
	echo -e "### DEBUG OUTPUT END ###"
fi

# Use dnadist to create the distance matrix.
# Then, move the file it creates where we want it to be
# Then, rename the IN_FILE so that the next script doesn't have
# any issues.

cd ${CLUSTAL_OUTPUT_DIR}
echo "Making the distance matrix..."
dnadist < ${DNADIST_SCRIPT}
mv outfile ${DISTANCES_FILE}
mv "${PHYLIP_IN_FILE}" "${PHYLIP_IN_FILE}.dnadist"