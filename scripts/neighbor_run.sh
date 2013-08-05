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
FINAL_TREE=${CLUSTAL_OUTPUT_DIR}/finaltree.txt
NAMEREPORT=${CLUSTAL_OUTPUT_DIR}/namereport

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

# Grab the helper functions to get
# generate the correct filenames for 
# HiTSAPipe's error checking.
source ${HELPER_FUNCTIONS}

SUCCESS_FILE=$(get_success)
FAILURE_FILE=$(get_failure)

# Make a script for neighbor based on the root we give
#echo "makeneighbor command: ${PERL_DIR}/makeneighbor.pl ${NEIGHBOR_DIR} ${NEIGHBOR_SCRIPT} ${NEIGHBOR_ROOT} ${PERL_DIR} ${PERL_DIR}/searchnames.pl"
${PERL_DIR}/makeneighbor.pl "${NEIGHBOR_DIR}" "${NEIGHBOR_SCRIPT}" "${NEIGHBOR_ROOT}" "${PERL_DIR}" "${PERL_DIR}/searchnames.pl"
RETVAL=$?
ERROR_MSG="makeneighbor encountered an unknown error."
NORMAL_MSG="makeneighbor has created the script for neighbor."
exit_if_error


# Generate the final tree given neighbor_script, which was created
# by makeneighbor.pl
cd ${NEIGHBOR_DIR}
echo "Making the tree..."
#echo "neighbor command: neighbor < ${NEIGHBOR_SCRIPT}"

neighbor < "${NEIGHBOR_SCRIPT}"
RETVAL=$?
ERROR_MSG="neighbor encountered an unknown error."
NORMAL_MSG="neighbor completed without errors."
exit_if_error


${PERL_DIR}/namesback.pl ${CLUSTAL_OUTPUT_DIR}
RETVAL=$?
ERROR_MSG="namesback.pl encountered an unknown error."
NORMAL_MSG="Names have been changed back to their full names."
exit_if_error

cd ${CLUSTAL_OUTPUT_DIR}
echo "Copying \"final\" output to ${FINAL_DIR}"
cp ${FINAL_TREE} ${NAMEREPORT} ${ALIGNMENT_POINTS_FILE} ${OUTPUT_XLS_ONE} ${OUTPUT_XLS_FIVE} ${HIT_NAMES_FILE} ${CLUSTAL_ALIGNMENT_FILE} ${CLUSTAL_PHYLIP_FILE} ${FINAL_DIR}
RETVAL=$?
ERROR_MSG="Could not move files to ${FINAL_DIR}"
NORMAL_MSG="Files moved successfully."
DEBUG_MSG="Final Directory: ${FINAL_DIR}"
exit_if_error

NORMAL_MSG="neighbor has finished."
exit_success