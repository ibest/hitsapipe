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
#	CLUSTAL_ALL_FILE
#	CLUSTAL_ALIGNMNET_FILE
#####

if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###"
	echo -e "\tCLUSTAL_ALL_FILE: ${CLUSTAL_ALL_FILE}"
	echo -e "\tCLUSTAL_ALIGNMENT_FILE: ${CLUSTAL_ALIGNMENT_FILE}"
	echo -e "### DEBUG OUTPUT END ###"
fi

# Grab the helper functions to get
# generate the correct filenames for 
# HiTSAPipe's error checking.
source ${HELPER_FUNCTIONS}

SUCCESS_FILE=$(get_success)
FAILURE_FILE=$(get_failure)

echo "Running clustalw2"
if [ ${EXECUTION} == "Parallel" ]
then
	mpiexec -np ${NNODES} clustalw-mpi -align -type=DNA -infile="${CLUSTAL_ALL_FILE}" -outfile="${CLUSTAL_ALIGNMENT_FILE}"
	RETVAL=$?
	ERROR_MSG="clustalw-mpi encountered a fatal error."
	NORMAL_MSG="clustalw-mpi finished running successfully."
	DEBUG_MSG="clustalw-mpi input file: ${CLUSTAL_ALL_FILE}"
	exit_if_error
else
	clustalw2 -align -type=DNA -infile="${CLUSTAL_ALL_FILE}" -outfile="${CLUSTAL_ALIGNMENT_FILE}"
	RETVAL=$?
	ERROR_MSG="clustalw (clustalw2) encountered a fatal error."
	NORMAL_MSG="clustalw (clustalw2) finished running successfully."
	DEBUG_MSG="clustalw (clustalw2) input file: ${CLUSTAL_ALL_FILE}"
	exit_if_error
fi

NORMAL_MSG="ClustalW2 alignment completed."
exit_success