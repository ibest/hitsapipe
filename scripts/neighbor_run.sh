#!/bin/bash

# ***** BEGIN LICENSE BLOCK *****
# Version: MPL 1.1
#
# The contents of this file are subject to the Mozilla Public License Version
# 1.1 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
#
# Contributor(s):
#
# ***** END LICENSE BLOCK *****

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