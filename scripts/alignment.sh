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
#	CLUSTAL_OUTPUT_DIR
#	CLUSTAL_ALIGNMENT_FILE
#	PHYLIP_IN_FILE
#####

if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###"
	echo -e "\tPERL_DIR: ${PERL_DIR}"
	echo -e "\tCLUSTAL_OUTPUT_DIR: ${CLUSTAL_OUTPUT_DIR}"
	echo -e "\tCLUTAL_ALIGNMENT_FILE: ${CLUSTAL_ALIGNMENT_FILE}"
	echo -e "\tPHYLIP_IN_FILE: ${PHYLIP_IN_FILE}"
	echo -e "### DEBUG OUTPUT END ###"
fi

# Grab the helper functions to get
# generate the correct filenames for 
# HiTSAPipe's error checking.
source ${HELPER_FUNCTIONS}

SUCCESS_FILE=$(get_success)
FAILURE_FILE=$(get_failure)

# Find the alignment start and end
echo "Getting alignment start and end"
${PERL_DIR}/findalign.pl < ${CLUSTAL_ALIGNMENT_FILE} > ${ALIGNMENT_POINTS_FILE}
RETVAL=$?
ERROR_MSG="Could not get alignment start and end."
NORMAL_MSG="Alignment found."
DEBUG_MSG="Alignment points found in ${ALIGNMENT_POINTS_FILE}"
exit_if_error

#gets start and end from a file
START=${START:-$(awk '/START/ {print $2}' ${ALIGNMENT_POINTS_FILE})}
#'
END=${END:-$(awk '/END/ {print $2}' ${ALIGNMENT_POINTS_FILE})}
#'

echo "START: ${START}"
echo "END: ${END}"

cd ${CLUSTAL_OUTPUT_DIR}

#Clipping the alignment file to the start and end, converting to phylip format
echo "Clipping the alignment"
seqret -sbegin $START -send $END clustal::${CLUSTAL_ALIGNMENT_FILE} phylip::${CLUSTAL_PHYLIP_FILE}
RETVAL=$?
ERROR_MSG="seqret could not clip the alignment."
NORMAL_MSG="Alignment clipped by seqret successfully."
exit_if_error

${PERL_DIR}/convert_clustal_to_phylip.pl < ${CLUSTAL_PHYLIP_FILE} > ${PHYLIP_IN_FILE}
RETVAL=$?
ERROR_MSG="Could not convert clustal file to phylip format."
NORMAL_MSG="Converted clustal file to phylip format."

#remove any file named outfile -- dnadist won't know what to do
rm -rf outfile

NORMAL_MSG="Alignment prepared successfully."
exit_success