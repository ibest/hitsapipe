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

# Collate all the sequences into one file
# for clustal in FASTA format. 

# rm -f clustal
echo "Collating all sequences"
cd ${CLUSTAL_OUTPUT_DIR}
cat ${REFERENCE_STRAINS} > ${CLUSTAL_FILE}


for FILE in `cat ${BLAST_INPUT_FILE}`
  do
    cat ${BLAST_TEMP_DIR}/${FILE} >> ${CLUSTAL_FILE}
  done

for FILE in `cat ${HIT_FILE}`
  do
    cat ${CLUSTAL_OUTPUT_DIR}/${FILE} >> ${CLUSTAL_FILE}
  done
  
# Give all the sequences a ten character ID which
# can be replaced with a real name later, otherwise
# the names are truncated by some of the following
# programs in a bad way!
cd ${CLUSTAL_OUTPUT_DIR}
echo "Shortening names to 10 characters"
echo "nameshort cmd: ${PERL_DIR}/nameshort.pl < ${CLUSTAL_FILE} > ${CLUSTAL_ALL_FILE}"
${PERL_DIR}/nameshort.pl < ${CLUSTAL_FILE} > ${CLUSTAL_ALL_FILE}