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

echo "Running clustalw2"
if [ ${EXECUTION} == "Parallel" ]
then
	echo "mpiexec/clustalw-mpi cmd: mpiexec -np ${NNODES} clustalw-mpi -align -type=DNA -infile="${CLUSTAL_ALL_FILE}" -outfile="${CLUSTAL_ALIGNMENT_FILE}""
	mpiexec -np ${NNODES} clustalw-mpi -align -type=DNA -infile="${CLUSTAL_ALL_FILE}" -outfile="${CLUSTAL_ALIGNMENT_FILE}"
		RETVAL=$?
	
	if [ ${RETVAL} != 0 ]
		then
			echo -e "\nERROR: clustalw-mpi could not complete."
			echo -e "\tclustalw-mpi exit code: ${RETVAL}"
			touch {ERROR_FILE}
			exit 1
	fi
else
	echo "clustalw2 cmd: clustalw2 -align -type=DNA -infile="${CLUSTAL_ALL_FILE}" -outfile="${CLUSTAL_ALIGNMENT_FILE}""
	clustalw2 -align -type=DNA -infile="${CLUSTAL_ALL_FILE}" -outfile="${CLUSTAL_ALIGNMENT_FILE}"
	RETVAL=$?
	
	if [ ${RETVAL} != 0 ]
		then
			echo -e "\nERROR: Unknown clustalw2 error."
			echo -e "\tclustalw2 exit code: ${RETVAL}"
			touch {ERROR_FILE}
			exit 1
	fi
fi