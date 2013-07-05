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
	echo -e "### DEBUG OUTPUT START ###"
	echo -e "\tINPUT_SEQUENCES: ${INPUT_SEQUENCES}"
	echo -e "\tPERL_DIR: ${PERL_DIR}"
	echo -e "\tORIGINALS_DIR: ${ORIGINALS_DIR}"
	echo -e "\tINPUT_SEQUENCES_LIST: ${INPUT_SEQUENCES_LIST}"
	echo -e "\tSUFFIX: ${SUFFIX}"
	echo -e "### DEBUG OUTPUT END ###"
fi

echo "Collating all ${SUFFIX} files into list"
find ${INPUT_SEQUENCES} -maxdepth 1 -name "*$SUFFIX" -exec basename {} \; > ${INPUT_SEQUENCES_LIST}

## Windows/Mac endlines to Unix endlines
echo "Ensuring Unix endlines on all files"
for FILE in $(cat ${INPUT_SEQUENCES_LIST})
  do
	echo "perl cmd: perl -p -i.orig -e 's/\r\n|\r/\n/g' ${INPUT_SEQUENCES}/${FILE}"
    perl -p -i.orig -e 's/\r\n|\r/\n/g' ${INPUT_SEQUENCES}/${FILE}
  done

#back up original files.
echo "Backing up original sequences."
find ${INPUT_SEQUENCES} -maxdepth 1 -name "*.orig" -print0 | xargs -i -0 mv {} ${ORIGINALS_DIR}

#With suffix denoting the suffix of the sequence FASTA files,
#changes their FASTA names to their filenames 
echo "Making sure all filenames are the FASTA sequences names."
cd ${INPUT_SEQUENCES}
EXITCODE=$(${PERL_DIR}/namechange.pl ${SUFFIX})$?

if [ ${EXITCODE} != 0 ]
then
	echo "ERROR: Filenames could not be change to FASTA sequence names. Exiting."
	touch ${ERROR_FILE}
fi

exit ${EXITCODE}