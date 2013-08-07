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

# Grab the helper functions to get
# generate the correct filenames for 
# HiTSAPipe's error checking.
source ${HELPER_FUNCTIONS}

SUCCESS_FILE=$(get_success)
FAILURE_FILE=$(get_failure)

if [ ${DEBUG} == "True" ]
then
	echo -e "${PBS_JOBNAME}: DEBUG: Variable List"
	echo -e "\tLOG_DIR: ${LOG_DIR}"
	echo -e "\tFINAL_LOG: ${FINAL_LOG}"
	echo -e "\tSUCCESS_FILE: ${SUCCESS_FILE}"
	echo -e "\tFAILURE_FILE: ${FAILURE_FILE}"
fi



# Concatenate all log files and places it into the output folder

for i in $(ls --sort=time -r `find ${PBS_O_WORKDIR} -name "*.log"`)
do
	BASE=$(basename $i)
	echo "From $BASE:" >> $FINAL_LOG
	cat $i >> $FINAL_LOG
	echo "" >> $FINAL_LOG
done

# Remove Job status directory
# Not removing this would let us see if there was a failure somewhere - 
# so should this be omitted and cleaned up on the next run?
# rm -rf ${JOB_STATUS_DIR}


# Cheat with the output, just append to concatenated log file.
if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###" >> $FINAL_LOG
	echo -e "\tLOG_DIR: ${LOG_DIR}" >> $FINAL_LOG
	echo -e "\tFINAL_LOG: ${FINAL_LOG}" >> $FINAL_LOG
	echo -e "### DEBUG OUTPUT END ###" >> $FINAL_LOG
fi

#echo "Creating final log file..." >> ${FINAL_LOG}
#echo "Deleting temporary files..." >> ${FINAL_LOG}
#echo "" >> ${FINAL_LOG}
echo -n "Everything finished at: $(date)" >> ${FINAL_LOG}
#date >> ${FINAL_LOG}
echo "" >> ${FINAL_LOG}

echo "Everything finished at: $(date)"