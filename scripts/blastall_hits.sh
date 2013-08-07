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
#	HIT_OUTPUT_DIR # Used to be called 8Fphylo
#	BLASTALL_OUTPUT_DIR
#	DATABASE
#	BLAST_OUT_5_FILE
#	HIT_SEQS_FILE
#	HIT_FILE
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
	echo -e "\tPERL_DIR: ${PERL_DIR}"
	echo -e "\tBLASTALL_OUTPUT_DIR: ${BLASTALL_OUTPUT_DIR}"
	echo -e "\tHIT_OUTPUT_DIR: ${HIT_OUTPUT_DIR}"
	echo -e "\tCLUSTAL_TEMP_DIR: ${CLUSTAL_TEMP_DIR}"
	echo -e "\tDATABASE: ${DATABASE}"
	echo -e "\tBLAST_OUT_5_FILE: ${BLAST_OUT_5_FILE}"
	echo -e "\tOUTPUT_XLS_ONE: ${OUTPUT_XLS_ONE}"
	echo -e "\tOUTPUT_XLS_FIVE: ${OUTPUT_XLS_FIVE}"
	echo -e "\tHIT_SEQS_FILE: ${HIT_SEQS_FILE}"
	echo -e "\tHIT_FILE: ${HIT_FILE}"
	echo -e "\tHIT_NAMES_FILE: ${HIT_NAMES_FILE}"
	echo -e "\tSUCCESS_FILE: ${SUCCESS_FILE}"
	echo -e "\tFAILURE_FILE: ${FAILURE_FILE}"
fi



#all the individual blasts into one file
echo "Concatenating the blast file"
find ${BLASTALL_OUTPUT_DIR} -name "*.blastn" -print0 | xargs -i -0 cat {} > ${BLAST_OUT_5_FILE}
RETVAL=$?
ERROR_MSG="Could not concatenate the blast file."
NORMAL_MSG="Blast file concatenated."
exit_if_error

echo "Parsing blast results"
#echo "blastparser cmd: ${PERL_DIR}/blastparser.pl ${BLAST_OUT_5_FILE} > ${HIT_OUTPUT_DIR}/output5.xls"
#echo "blastcull cmd: ${PERL_DIR}/blastcull.pl < ${HIT_OUTPUT_DIR}/output5.xls > ${HIT_OUTPUT_DIR}/output1.xls"
${PERL_DIR}/blastparser.pl ${BLAST_OUT_5_FILE} > ${OUTPUT_XLS_FIVE}
RETVAL=$?
ERROR_MSG="Could not parse blast results."
NORMAL_MSG="Blast results parsed."
exit_if_error

cd ${HIT_OUTPUT_DIR}
${PERL_DIR}/blastcull.pl < ${OUTPUT_XLS_FIVE} > ${OUTPUT_XLS_ONE}
RETVAL=$?
ERROR_MSG="Could not cull blast results."
NORMAL_MSG="Blast results culled."
exit_if_error


cd ${HIT_OUTPUT_DIR}
cut -f3,4 ${OUTPUT_XLS_FIVE} > ${HIT_OUTPUT_DIR}/hitnames_long5.xls
RETVAL=$?
ERROR_MSG="Could not create Long5 hit spreadsheet."
exit_if_error

cut -f3,4 ${OUTPUT_XLS_ONE} > ${HIT_OUTPUT_DIR}/hitnames_long1.xls
RETVAL=$?
ERROR_MSG="Could not create Long1 hit spreadsheet."
NORMAL_MSG="Hit spreadsheets created."
exit_if_error


echo "Making hit statistics."
#echo "hit_statistics cmd: ${PERL_DIR}/hit_statistics.pl ${OUTPUT_XLS_ONE} ${HIT_OUTPUT_DIR}/hit_statistics.xls"
cd ${HIT_OUTPUT_DIR}
${PERL_DIR}/hit_statistics.pl ${HIT_OUTPUT_DIR}/output1.xls ${HIT_OUTPUT_DIR}/hit_statistics.xls
RETVAL=$?
ERROR_MSG="Could not create hit statistics."
NORMAL_MSG="Hit statistics created."
exit_if_error

echo -e "Getting the unique hits:\n"
sort -u ${HIT_OUTPUT_DIR}/hitnames_long1.xls > ${HIT_NAMES_FILE}
RETVAL=$?
ERROR_MSG="Could not get the unique hits."
NORMAL_MSG="Got the unique hits."
exit_if_error

cat ${HIT_NAMES_FILE}
echo -e "\n"

# Get a list of the lowercase IDs for the sequences.
# Also, make a list of the to-be filesnames for the sequences
awk '{print $1 }' ${HIT_OUTPUT_DIR}/hitnames | tr '[A-Z]' '[a-z]' > ${HIT_OUTPUT_DIR}/hitseqs1
sort ${HIT_OUTPUT_DIR}/hitseqs1 > ${HIT_SEQS_FILE}
rm ${HIT_OUTPUT_DIR}/hitseqs1 # Was just a temp file.
sed "s/$/.fasta/g" ${HIT_SEQS_FILE} > ${HIT_FILE}

# Copy the file from the database sequences folder to the blast directory
echo "${PBS_JOBNAME}: Fetching the hit sequences from the database"
for NAME in `cat ${HIT_SEQS_FILE}`
	do
	if [ ${DEBUG} == "True" ]
	then 
    	echo "${PBS_JOBNAME}: DEBUG: Fetching ${DATABASE}:${NAME}"
    fi
	fastacmd -d ${DATABASE} -p F -s $NAME > "${CLUSTAL_TEMP_DIR}/${NAME}.fasta"
		if [ ! -e "${CLUSTAL_TEMP_DIR}/$NAME.fasta" ]
		then
			echo "${PBS_JOBNAME}: WARNING:  Could not fetch $NAME.fasta!"
		fi
	done
	
NORMAL_MSG="All hit statistics and spreadsheets created without error."
exit_success