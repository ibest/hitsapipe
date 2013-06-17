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
echo "makeneighbor command: ${PERL_DIR}/makeneighbor.pl ${NEIGHBOR_DIR} ${NEIGHBOR_ROOT} ${PERL_DIR} ${PERL_DIR}/searchnames.pl"
RETVAL=$(${PERL_DIR}/makeneighbor.pl ${NEIGHBOR_DIR} ${NEIGHBOR_ROOT} ${PERL_DIR} ${PERL_DIR}/searchnames.pl)$?

if [ ${RETVAL} != 0 ]
	then
		echo -e "\nERROR: Unknown makeneighbor error."
		echo -e "\tmakeneighbor exit code: ${RETVAL}"
		exit 1
fi

# Generate the final tree given neighbor_script, which was created
# by makeneighbor.pl
cd ${NEIGHBOR_DIR}
echo "Making the tree"
echo "neighbor command: neighbor < ${NEIGHBOR_SCRIPT}"
RETVAL=$(neighbor < ${NEIGHBOR_SCRIPT})$?

if [ ${RETVAL} != 0 ]
	then
		echo -e "\nERROR: Unknown neighbor error."
		echo -e "\tneighbor exit code: ${RETVAL}"
		exit 1
fi

echo "Changing back to full names"
echo namesback command: ${PERL_DIR}/namesback.pl ${CLUSTAL_OUTPUT_DIR}"
RETVAL=$(${PERL_DIR}/namesback.pl ${CLUSTAL_OUTPUT_DIR})$?

if [ ${RETVAL} != 0 ]
	then
		echo -e "\nERROR: Unknown namesback error."
		echo -e "\tnamesback exit code: ${RETVAL}"
		exit 1
fi