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
#	CLUSTAL_ALIGNMENT_FILE
#####

# Grab the helper functions to get
# generate the correct filenames for 
# HiTSAPipe's error checking.
source ${HELPER_FUNCTIONS}

SUCCESS_FILE=$(get_success)
FAILURE_FILE=$(get_failure)

if [ ${DEBUG} == "True" ]
then
	echo -e "${PBS_JOBNAME}: DEBUG: Variable List"
	echo -e "\tCLUSTAL_ALIGNMENT_FILE: ${CLUSTAL_ALIGNMENT_FILE}"
	echo -e "\tSUCCESS_FILE: ${SUCCESS_FILE}"
	echo -e "\tFAILURE_FILE: ${FAILURE_FILE}"
fi

#Check that an alignment has been made
if [ ! -f ${CLUSTAL_ALIGNMENT_FILE} ]
 then
	RETVAL=1
	ERROR_MSG="ClustalW did not make an alignment!"
	DEBUG_MSG="Could not find ${CLUSTAL_ALIGNMENT_FILE}"
	exit_if_error
fi

NORMAL_MSG="ClustalW successfully made an alignment."
exit_success