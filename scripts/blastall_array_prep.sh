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
#	ARRAY_OUTPUT_FILE: 			File that stores the number of jobs in the array.
#	BLAST_INPUT_FILE: 			File that has list of files to count.
#	BLAST_TEMP_DIR: 			Directory where good fasta files are.
#####
# Additional:
#	NUMFILES: 					Number of jobs in the array.
#	FILE: 						Used in renaming the fasta files for blastall.
#	ITER: 						Simple iterator for renaming files.
#####

# Grab the helper functions to get
# generate the correct filenames for 
# HiTSAPipe's error checking.
source ${HELPER_FUNCTIONS}

SUCCESS_FILE=$(get_success)
FAILURE_FILE=$(get_failure)

# Set up variables for parallel run
DBNODES=$((NNODES - 2))
DBNAME=$(echo "${DATABASE##*/}")
	
	
if [ ${DEBUG} == "True" ]
then
	echo -e "Debug: Variable List"
	echo -e "\tBLAST_TEMP_DIR: ${BLAST_TEMP_DIR}"
	echo -e "\tBLAST_INPUT_FILE: ${BLAST_INPUT_FILE}"
	if [ "${EXECUTION}" == "Parallel" ]
	then
		echo -e "Debug: Parallel Variables"
		echo -e "\tDATABASE: ${DATABASE}"
		echo -e "\tDBNAME: ${DBNAME}"
		echo -e "\tNNODES: ${NNODES}"
		echo -e "\tDBNODES: ${DBNODES}"
		echo -e "\tLOG_DIR: ${LOG_DIR}"
	fi
fi


# Find the number of sequences in the input file to create a counter for
# renaming everything.
# Move into the temp directory where the fasta files are for renaming
# purposes.

ITER=0

cd ${BLAST_TEMP_DIR}

for FILE in $(cat ${BLAST_INPUT_FILE})
do
	mv "${FILE}" "${FILE}.${ITER}"
	RETVAL=$?
	ERROR_MSG="Could not rename ${FILE}"
	DEBUG_MSG="Rename ${FILE} to ${FILE}.${ITER}"
	((ITER++))
done
RETVAL=0
NORMAL_MSG="Input files renamed for blasting."
DEBUG_MSG="${ITER} files renamed."
exit_if_error


if [ "${EXECUTION}" == "Parallel" ]
then
	mpiformatdb -N ${DBNODES} -i ${DATABASE} -t ${DBNAME} -n ${DBNAME} --skip-reorder -p F -l "${LOG_DIR}/mpiformatdb_blastall.log"
	RETVAL=$?
	ERROR_MSG="mpiformatdb could not format the database for mpiBLAST."
	NORMAL_MSG="Database formatted for mpiBLAST."
	exit_if_error
fi

# Set ITER to TO_LOG so that it logs to the success file
TO_LOG="${ITER}"
echo "${ITER}" > ${ARRAY_OUTPUT_FILE} # Will be deleted.

NORMAL_MSG="Prepared to BLAST sequences."
exit_success