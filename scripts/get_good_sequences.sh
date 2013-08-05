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
#	INPUT_SEQUENCES: 				The directory with the sequences
#	PERL_DIR: 					The perl script directory
#	BLAST_DIR: 					The directory for blast files
#	INPUT_SEQUENCES_FILE: 		The file to store the list of input sequences for processing
#	GOOD_SEQUENCES_FILE: 		The file to store the good sequences in
#	SUFFIX: 					The fasta file file extension
#	DIRECTION: 					The direction of the sequences
#	NPERCENT: 					The percentage of Ns allowed before failing
#	PRIMER3: 					Primer on the 3' end
#	PRIMER5: 					Primer of the 5' end
#	MIN_SEQUENCE_LENGTH: 		Minimum length needed for a sequence to be accepted
#####

if [ ${DEBUG} == "True" ]
then
	echo -e "DEBUG: Variable List"
	echo -e "\tINPUT_SEQUENCES: ${INPUT_SEQUENCES}"
	echo -e "\tPERL_DIR: ${PERL_DIR}"
	echo -e "\tBLAST_DIR: ${BLAST_DIR}"
	echo -e "\tINPUT_SEQUENCES_FILE: ${INPUT_SEQUENCES_FILE}"
	echo -e "\tGOOD_SEQUENCES_FILE: ${GOOD_SEQUENCES_FILE}"
	echo -e "\tSUFFIX: ${SUFFIX}"
	echo -e "\tDIRECTION: ${DIRECTION}"
	echo -e "\tNPERCENT: ${NPERCENT}"
	echo -e "\tPRIMER3: ${PRIMER3}"
	echo -e "\tPRIMER5: ${PRIMER5}"
	echo -e "\tMIN_SEQUENCE_LENGTH: ${MIN_SEQUENCE_LENGTH}"
fi

# Grab the helper functions to get
# generate the correct filenames for 
# HiTSAPipe's error checking.
source ${HELPER_FUNCTIONS}

SUCCESS_FILE=$(get_success)
FAILURE_FILE=$(get_failure)

find ${INPUT_SEQUENCES} -maxdepth 1 -name "*${SUFFIX}" -print0 | xargs -i -0 cat {} >> ${INPUT_SEQUENCES_FILE}
RETVAL=$?
ERROR_MSG="Could not collate sequences."
NORMAL_MSG="Input sequences collated."
DEBUG_MSG="Used INPUT_SEQUENCES, SUFFIX and INPUT_SEQUENCES_FILE"
exit_if_error


#This part tries to figure out whether a sequence is valid --
#make the percentage cutoff for countN2 a parameter and whether to do this
#a parameter as well

cd ${INPUT_SEQUENCES}
${PERL_DIR}/countN2.pl ${NPERCENT} ${PRIMER3} ${PRIMER5} ${MIN_SEQUENCE_LENGTH} < ${INPUT_SEQUENCES_FILE} > ${GOOD_SEQUENCES_FILE}
RETVAL=$?
ERROR_MSG="countN2.pl encountered an error while finding valid sequences."
NORMAL_MSG="Finished searching for all valid sequences."
DEBUG_MSG="Valid sequences placed in ${GOOD_SEQUENCES_FILE}"
exit_if_error
cd ${PBS_O_WORKDIR}



if [ ! -e ${GOOD_SEQUENCES_FILE} ] || [ ! -s ${GOOD_SEQUENCES_FILE} ]
then
	RETVAL=1
	ERROR_MSG="No good sequences were found!"
	DEBUG_MSG="Good sequences file doesn't exist or is empty."
	exit_if_error
fi

#If our direction is REVERSE, then we will reverse the sequences within
#goodseqs and replace it with the reversed sequences
case ${DIRECTION} in 
	REVERSE|reverse|R|r)
		seqret -srev -sequence ${GOOD_SEQUENCES_FILE} -offormat2 fasta -outseq revseqs -auto
		RETVAL=$?
		ERROR_MSG="seqret could not reverse the sequences."
		NORMAL_MSG="seqret successfully reversed the sequences."
		DEBUG_MSG="Direction (${DIRECTION})"
		exit_if_error
		
		mv ${GOOD_SEQUENCES_FILE} ${BLAST_DIR}/beforereverse
		RETVAL=$?
		ERROR_MSG="Could not reverse sequences (possible permission error?)"
		DEBUG_MSG="Good sequences file renamed to 'beforereverse'."
		exit_if_error
		
		mv ${BLASTDIR}/revseqs ${GOOD_SEQUENCES_FILE}
		RETVAL=$?
		ERROR_MSG="Could not reverse sequences (possible permission error?)."
		NORMAL_MSG="Sequences reversed successfully."
		DEBUG_MSG="'revseqs' renamed to good sequences file."
		exit_if_error
esac

if [ ! -e ${GOOD_SEQUENCES_FILE} ] || [ ! -s ${GOOD_SEQUENCES_FILE} ]
then
	RETVAL=1
	ERROR_MSG="No good sequences were found after reversing!"
	DEBUG_MSG="Good sequences file doesn't exist or is empty."
	exit_if_error
fi

NORMAL_MSG="All valid sequences found."
exit_success