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
#	BLAST_TEMP_DIR
#	ARRAY_OUTPUT_FILE
#	REF_STRAINS_FILE
#	CLUSTAL_FILE
#	CLUSTAL_ALL_FILE
#	BLAST_INPUT_FILE
#	HIT_FILE

if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###"
	echo -e "\tPERL_DIR: ${PERL_DIR}"
	echo -e "\tCLUSTAL_OUTPUT_DIR: ${CLUSTAL_OUTPUT_DIR}"
	echo -e "\tBLAST_TEMP_DIR: ${BLAST_TEMP_DIR}"
	echo -e "\tARRAY_OUTPUT_FILE: ${ARRAY_OUTPUT_FILE}"
	echo -e "\tREFERENCE_STRAINS: ${REFERENCE_STRAINS}"
	echo -e "\tCLUSTAL_FILE: ${CLUSTAL_FILE}"
	echo -e "\tCLUSTAL_ALL_FILE: ${CLUSTAL_ALL_FILE}"
	echo -e "\tBLAST_INPUT_FILE: ${BLAST_INPUT_FILE}"
	echo -e "\tHIT_FILE: ${HIT_FILE}"
	echo -e "### DEBUG OUTPUT END ###"
fi

# Grab the helper functions to get
# generate the correct filenames for 
# HiTSAPipe's error checking.
source ${HELPER_FUNCTIONS}

SUCCESS_FILE=$(get_success)
FAILURE_FILE=$(get_failure)

# Collate all the sequences into one file
# for clustal in FASTA format. 

cd ${CLUSTAL_OUTPUT_DIR}
cat ${REFERENCE_STRAINS} > ${CLUSTAL_FILE}
RETVAL=$?
ERROR_MSG="Could not collate reference strains."
NORMAL_MSG="Collated sequences for clustal."
DEBUG_MSG="Copied reference strains into ${CLUSTAL_FILE}"
exit_if_error


for FILE in `cat ${BLAST_INPUT_FILE}`
  do
    cat ${BLAST_TEMP_DIR}/${FILE} >> ${CLUSTAL_FILE}
    RETVAL=$?
    ERROR_MSG="Could not copy (from blast input file): ${FILE}"
    exit_if_error
  done

for FILE in `cat ${HIT_FILE}`
  do
    cat ${CLUSTAL_TEMP_DIR}/${FILE} >> ${CLUSTAL_FILE}
    RETVAL=$?
    ERROR_MSG="Could not copy (from hit file): ${FILE}"
    exit_if_error
  done
  
# Give all the sequences a ten character ID which
# can be replaced with a real name later, otherwise
# the names are truncated by some of the following
# programs in a bad way!
cd ${CLUSTAL_OUTPUT_DIR}
${PERL_DIR}/nameshort.pl < ${CLUSTAL_FILE} > ${CLUSTAL_ALL_FILE}
RETVAL=$?
ERROR_MSG="Could not shorten names."
NORMAL_MSG="Shortened all names to 10 characters for clustalw."
exit_if_error

NORMAL_MSG="Successfully prepped for clustalw."
exit_success