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
#	DEBUG
#####

NEIGHBOR_SCRIPT=${NEIGHBOR_DIR}/neighbor_script

if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###"
	echo -e "\tPERL_DIR: ${PERL_DIR}"
	echo -e "\tNEIGHBOR_DIR: ${NEIGHBOR_DIR}"
	echo -e "\tNEIGHBOR_ROOT: ${NEIGHBOR_ROOT}"
	echo -e "\tNEIGHBOR_SCRIPT: ${NEIGHBOR_SCRIPT}"
	echo -e "\tCLUSTAL_OUTPUT_DIR: ${CLUSTAL_OUTPUT_DIR}"
	echo -e "\tTREE_DIR: ${TREE_DIR}"
	echo -e "### DEBUG OUTPUT END ###"
fi

# Make a script for neighbor based on the root we give
#echo "makeneighbor command: ${PERL_DIR}/makeneighbor.pl ${NEIGHBOR_DIR} ${NEIGHBOR_SCRIPT} ${NEIGHBOR_ROOT} ${PERL_DIR} ${PERL_DIR}/searchnames.pl"
${PERL_DIR}/makeneighbor.pl "${NEIGHBOR_DIR}" "${NEIGHBOR_SCRIPT}" "${NEIGHBOR_ROOT}" "${PERL_DIR}" "${PERL_DIR}/searchnames.pl"
RETVAL=$?

if [ ${RETVAL} != 0 ]
	then
		echo -e "\nERROR: Unknown makeneighbor error."
		echo -e "\tmakeneighbor exit code: ${RETVAL}"
		touch {ERROR_FILE}
		exit 1
fi
echo "Created the script for neighbor to use."


# Generate the final tree given neighbor_script, which was created
# by makeneighbor.pl
cd ${NEIGHBOR_DIR}
echo "Making the tree..."
#echo "neighbor command: neighbor < ${NEIGHBOR_SCRIPT}"

neighbor < "${NEIGHBOR_SCRIPT}"
RETVAL=$?
if [ ${RETVAL} != 0 ]
	then
		echo -e "\nERROR: Unknown neighbor error."
		echo -e "\tneighbor exit code: ${RETVAL}"
		touch {ERROR_FILE}
		exit 1
fi


echo "Changing back to full names..."
#echo "namesback command: ${PERL_DIR}/namesback.pl ${CLUSTAL_OUTPUT_DIR}"

${PERL_DIR}/namesback.pl ${CLUSTAL_OUTPUT_DIR}
RETVAL=$?

if [ ${RETVAL} != 0 ]
	then
		echo -e "\nERROR: Unknown namesback.pl error."
		echo -e "\tnamesback.pl exit code: ${RETVAL}"
		touch {ERROR_FILE}
		exit 1
fi

echo "Moving \"final\" output to ${TREE_DIR}"
mv ${CLUSTAL_OUTPUT_DIR}/final* ${TREE_DIR}/
RETVAL=$?

if [ ${RETVAL} != 0 ]
	then
		echo -e "\nERROR: Cannot move files to ${TREE_DIR}."
		echo -e "\tmv exit code: ${RETVAL}"
		touch {ERROR_FILE}
		exit 1
fi