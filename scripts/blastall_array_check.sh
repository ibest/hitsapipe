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
#	BLASTALL_OUTPUT_DIR: 	Directory with the blastall result files
#	BLAST_INPUT_FILE: 		List of the sequences that should have blast output
#	NUMSEQS_TEMP_FILE: 		Contains the number of sequences that should have been blasted
#####
# Additional:
#	NUMSEQS: 				Number of sequences that should have been blasted.
#	NUMBLASTS: 				Number of sequences actually blasted.
#####

# Grab the helper functions to get
# generate the correct filenames for 
# HiTSAPipe's error checking.
source ${HELPER_FUNCTIONS}

SUCCESS_FILE=$(get_success)
FAILURE_FILE=$(get_failure)

NUMSEQS=$(cat ${NUMSEQS_TEMP_FILE})
NUMBLASTS=$(find ${BLASTALL_OUTPUT_DIR} -name "*.blastn" | wc -l)

if [ ${DEBUG} == "True" ]
then
	echo -e "${PBS_JOBNAME}: DEBUG: Variable List"
	echo -e "\tBLASTALL_OUTPUT_DIR: ${BLASTALL_OUTPUT_DIR}"
	echo -e "\tBLAST_INPUT_FILE: ${BLAST_INPUT_FILE}"
	echo -e "\tNUMSEQS_TEMP_FILE: ${NUMSEQS_TEMP_FILE}"
	echo -e "\tNUMSEQS: ${NUMSEQS}"
	echo -e "\tNUMBLASTS: ${NUMBLASTS}"
	echo -e "\tSUCCESS_FILE: ${SUCCESS_FILE}"
	echo -e "\tFAILURE_FILE: ${FAILURE_FILE}"
fi



# preliminary check that we have all the needed blasts
if [ ${NUMBLASTS} == 0 ]
then
	RETVAL=1
	ERROR_MSG="No blasts found!"
	exit_if_error
elif [ ${NUMBLASTS} -ne ${NUMSEQS} ] # Could also have NUMBLASTS != NUMSEQS
then
	echo "Number of blasts doesn't equal number of good sequences!"
	echo "Checking for missing blasts."
  
	for FILE in `cat ${BLAST_INPUT_FILE}` 
		do
    	if [ ! -e "${FILE}.blastn" ]
    	then
    		RETVAL=0
    		NORMAL_MSG="WARNING: ${FILE} has no BLAST output!"
    		exit_if_error
    	fi
	done
fi

NORMAL_MSG="Number of blasts found: ${NUMBLASTS}"
exit_success