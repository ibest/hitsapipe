#!/bin/bash
#####
# Requires:
#	PERL_DIR
#	NEIGHBOR_DIR
#	NEIGHBOR_ROOT
#	CLUSTAL_OUTPUT_DIR
#####
# Additional:
#	NEIGHBOR_SCRIPT
#####

NEIGHBOR_SCRIPT=${NEIGHBOR_DIR}/neighbor_script
echo -e "Debug start..."
echo -e "\tNEIGHBOR_DIR: ${NEIGHBOR_DIR}"
echo -e "\tNEIGHBOR_SCRIPT: ${NEIGHBOR_SCRIPT}"
echo -e "\tNEIGHBOR_ROOT: ${NEIGHBOR_ROOT}"
echo -e "Debug end..."

# Make a script for neighbor based on the root we give
#echo "makeneighbor command: ${PERL_DIR}/makeneighbor.pl ${NEIGHBOR_DIR} ${NEIGHBOR_ROOT} ${PERL_DIR} ${PERL_DIR}/searchnames.pl"
${PERL_DIR}/makeneighbor.pl "${NEIGHBOR_DIR}" "${NEIGHBOR_ROOT}" "${PERL_DIR}" "${PERL_DIR}/searchnames.pl"
RETVAL=$?

if [ ${RETVAL} != 0 ]
	then
		echo -e "\nERROR: Unknown makeneighbor error."
		echo -e "\tmakeneighbor exit code: ${RETVAL}"
		exit 1
fi
echo "Created the script for neighbor to use."


# Generate the final tree given neighbor_script, which was created
# by makeneighbor.pl
cd ${NEIGHBOR_DIR}
echo -n "Making the tree..."
#echo "neighbor command: neighbor < ${NEIGHBOR_SCRIPT}"

neighbor < "${NEIGHBOR_SCRIPT}"
RETVAL=$?
if [ ${RETVAL} != 0 ]
	then
		echo -e "\nERROR: Unknown neighbor error."
		echo -e "\tneighbor exit code: ${RETVAL}"
		exit 1
fi
echo "Done."


echo -n "Changing back to full names..."
#echo "namesback command: ${PERL_DIR}/namesback.pl ${CLUSTAL_OUTPUT_DIR}"

${PERL_DIR}/namesback.pl ${CLUSTAL_OUTPUT_DIR}
RETVAL=$?

if [ ${RETVAL} != 0 ]
	then
		echo -e "\nERROR: Unknown namesback.pl error."
		echo -e "\tnamesback.pl exit code: ${RETVAL}"
		exit 1
fi
echo "Done."