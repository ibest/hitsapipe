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
#	SEQUENCE_DIR: 			The directory with the sequences
#	PERL_DIR: 				The perl script directory
#	ORIGINALS_DIR: 			The directory of where to place the originals (backups).
#	INPUT_SEQUENCES_LIST: 	The the location of where to store the list
#	SUFFIX: 				The file extension of the sequence files
#####

if [ ${DEBUG} == "True" ]
then
	echo -e "DEBUG: Variable List"
	echo -e "\tREFERENCES_DIR: ${REFERENCES_DIR}"
	echo -e "\tPERL_DIR: ${PERL_DIR}"
	echo -e "\tORIGINALS_DIR: ${ORIGINALS_DIR}"
	echo -e "\tREFERENCE_STRAINS: ${REFERENCE_STRAINS}"
	echo -e "\tBLAST_SEQUENCES: ${BLAST_SEQUENCES}"
	echo -e "\tINPUT_SEQUENCES: ${INPUT_SEQUENCES}"
	echo -e "\tINPUT_SEQUENCES_LIST: ${INPUT_SEQUENCES_LIST}"
	echo -e "\tSUFFIX: ${SUFFIX}"
fi

# Grab the helper functions to get
# generate the correct filenames for 
# HiTSAPipe's error checking.
source ${HELPER_FUNCTIONS}

SUCCESS_FILE=$(get_success)
FAILURE_FILE=$(get_failure)

# Backup the reference strains and blast sequences files.
cp ${REFERENCE_STRAINS} ${REFERENCES_DIR}/
RETVAL=$?
ERROR_MSG="Cannot copy reference strains file."
NORMAL_MSG="Reference strains file copied to backup directory."
DEBUG_MSG="Copied REFERENCE_STRAINS to REFERENCES_DIR." 
exit_if_error

cp ${BLAST_SEQUENCES} ${REFERENCES_DIR}/
RETVAL=$?
ERROR_MSG="Cannot copy blast sequences file."
NORMAL_MSG="Blast sequences file copied to backup directory."
DEBUG_MSG="Copied BLAST_SEQUENCES to REFERENCES_DIR."
exit_if_error


find ${INPUT_SEQUENCES} -maxdepth 1 -name "*$SUFFIX" -exec basename {} \; > ${INPUT_SEQUENCES_LIST}
RETVAL=$?
ERROR_MSG="Could not collate ${SUFFIX} files into list."
NORMAL_MSG="All ${SUFFIX} files collated into list."
DEBUG_MSG="Variables used: SUFFIX, INPUT_SEQUENCES and INPUT_SEQUENCES_LIST."
exit_if_error


## Windows/Mac endlines to Unix endlines
for FILE in $(cat ${INPUT_SEQUENCES_LIST})
  do
    perl -p -i.orig -e 's/\r\n|\r/\n/g' ${INPUT_SEQUENCES}/${FILE}
    RETVAL=$?
    ERROR_MSG="Could not strip endlines from ${FILE}."
    DEBUG_MSG="Converting to UNIX endlines: ${FILE}"
    exit_if_error
  done
echo "All endlines converted to UNIX endlines."


#back up original files.
find ${INPUT_SEQUENCES} -maxdepth 1 -name "*.orig" -print0 | xargs -i -0 mv {} ${ORIGINALS_DIR}
RETVAL=$?
ERROR_MSG="Could not back up original sequences."
NORMAL_MSG="Original sequences backed up."
DEBUG_MSG="Variables used: INPUT_SEQUENCES and ORIGINALS_DIR"
exit_if_error

#With suffix denoting the suffix of the sequence FASTA files,
#changes their FASTA names to their filenames 
cd ${INPUT_SEQUENCES}
${PERL_DIR}/namechange.pl ${SUFFIX}
RETVAL=$?
ERROR_MSG="Could not change all filenames to FASTA sequence names."
NORMAL_MSG="All filenames have been changed to FASTA sequence names."
DEBUG_MSG="Variables used: INPUT_SEQUENCES, PERL_DIR and SUFFIX"
exit_if_error

NORMAL_MSG="FASTA files have been prepared."
exit_success