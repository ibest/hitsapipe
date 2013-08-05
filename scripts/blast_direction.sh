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
#	TEMP_DIR: 				Directory to place the temporary files in.
#	PERL_DIR: 				Directory where the perl scripts are located.
#	LOG_DIR: 				Directory where all log files go.
#	BLAST_TEMP_DIR: 		Directory to place the good fasta files in.
#	GOOD_SEQUENCES_FILE: 	File that contains the good sequences.
#	DIRECTION_BLAST_FILE: 	File that contains blastall's output for direction.
#	BLAST_INPUT_FILE: 		File to store the matched names.
#	NUMSEQS_TEMP_FILE: 		Holds the number of good sequences for later comparison
#	BLAST_SEQUENCES: 		Sequences to be blasted against.
#	CUTOFF_LENGTH: 			
#	PARALLEL: 				Determines if we are running in parallel or not
#	NNODES: 				If parallel, how many nodes to run on
#	MPIBLAST_SHARED: 		Directory where the mpiformatdb places the database.
#####
# Additional:
#	NUMSEQS: 				Number of good sequences that are found.
#	STRAND_IN_FILE: 		Temporary file for blastpicks/blastadd.
#	STRAND_FILE: 			Temporary file for blastpicks/blastadd.
#	MPINODES: 				If parallel, how many nodes mpiformatdb should use.
#####

STRAND_FILE="${BLAST_TEMP_DIR}/strands"
STRAND_IN_FILE="${BLAST_TEMP_DIR}/strandin"
DBNODES=$((NNODES - 2))
DBNAME=$(echo "${GOOD_SEQUENCES_FILE##*/}")
GOOD_SEQUENCES_SHARED=$(echo "${GOOD_SEQUENCES_FILE##*/}")

if [ ${DEBUG} == "True" ]
then
	echo -e "Debug: Variable List"
	echo -e "\tPERL_DIR: ${PERL_DIR}"
	echo -e "\tLOG_DIR: ${LOG_DIR}"
	echo -e "\tBLAST_TEMP_DIR: ${BLAST_TEMP_DIR}"
	echo -e "\tGOOD_SEQUENCES_FILE: ${GOOD_SEQUENCES_FILE}"
	echo -e "\tDIRECTION_BLAST_FILE: ${DIRECTION_BLAST_FILE}"
	echo -e "\tBLAST_INPUT_FILE: ${BLAST_INPUT_FILE}"
	echo -e "\tNUMSEQS_TEMP_FILE: ${NUMSEQS_TEMP_FILE}"
	echo -e "\tBLAST_SEQUENCES: ${BLAST_SEQUENCES}"
	echo -e "\tCUTOFF_LENGTH: ${CUTOFF_LENGTH}"
	if [ "${EXECUTION}" == "Parallel" ]
	then
		echo -e "Debug: Parallel Variables"
		echo -e "\tSTRAND_FILE: ${STRAND_FILE}"
		echo -e "\tSTRAND_IN_FILE: ${STRAND_IN_FILE}"
		echo -e "\tDBNODES: ${DBNODES}"
		echo -e "\tDBNAME: ${DBNAME}"
		echo -e "\tGOOD_SEQUENCES_SHARED: ${GOOD_SEQUENCES_SHARED}"
	fi
fi

# Grab the helper functions to get
# generate the correct filenames for 
# HiTSAPipe's error checking.
source ${HELPER_FUNCTIONS}

SUCCESS_FILE=$(get_success)
FAILURE_FILE=$(get_failure)
# Format the good sequences into a database to blast against 
# with our sample sequence.
# If this is to be run in parallel, call mpiformatdb
# If not, call formatdb

if [ "${EXECUTION}" == "Parallel" ]
then

 	#echo "Running mpiformatdb to format the good sequences into a database to blast against with out sample sequence."
 	#fastacmd -D 1 -d ${GOOD_SEQUENCES_FILE} | mpiformatdb -N ${DBNODES} -i stdin --skip-reorder -n ${DBNAME} -t ${DBNAME} -p F -o T -l ${LOG_DIR}/mpiformatdb_direction.log
 	#echo "mpiformatdb cmd: mpiformatdb -N ${DBNODES} -i ${GOOD_SEQUENCES_FILE} -p F -o T -l ${LOG_DIR}/mpiformatdb_direction.log"
 	mpiformatdb -N ${DBNODES} -i ${GOOD_SEQUENCES_FILE} -p F -o T -l ${LOG_DIR}/mpiformatdb_direction.log
 	RETVAL=$?
	ERROR_MSG="mpiformatdb could not format the good sequences."
	NORMAL_MSG="Formatted the good sequences for mpiblast."
	exit_if_error
	

	cd ${MPIBLAST_SHARED}
	mpiexec -v -np ${NNODES} mpiblast -p blastn -d ${GOOD_SEQUENCES_SHARED} -i ${BLAST_SEQUENCES} -S 1 -o ${DIRECTION_BLAST_FILE} -z 53,000,000 -b 10000 --removedb
	RETVAL=$?
	ERROR_MSG="mpiblast encountered an error while determining the direction."
	NORMAL_MSG="mpiBLAST was able to determine direction of blast sequences."
	DEBUG_MSG="BLASTed ${BLAST_SEQUENCES} against ${GOOD_SEQUENCES_SHARED}"
	exit_if_error
else
	formatdb -i ${GOOD_SEQUENCES_FILE} -p F -o T -l ${LOG_DIR}/formatdb_direction.log
	RETVAL=$?
	ERROR_MSG="formatdb could not format the good sequences."
	NORMAL_MSG="Formatted the good sequences for blastall."
	exit_if_error
	
	blastall -p blastn -d ${GOOD_SEQUENCES_FILE} -i ${BLAST_SEQUENCES} -S 1 -o ${DIRECTION_BLAST_FILE} -z 53,000,000 -b 10000
	RETVAL=$?
	ERROR_MSG="blastall encountered an error while determining the direction."
	NORMAL_MSG="blastall was able to determine direction of blast sequences."
	DEBUG_MSG="BLASTed ${BLAST_SEQUENCES} against ${GOOD_SEQUENCES_FILE}."
	exit_if_error
fi

${PERL_DIR}/blastpicks.pl ${DIRECTION_BLAST_FILE} > ${STRAND_FILE}
RETVAL=$?
ERROR_MSG="blastpicks.pl encountered an unknown error."
exit_if_error

${PERL_DIR}/blastadd.pl ${CUTOFF_LENGTH} < ${STRAND_FILE} > ${STRAND_IN_FILE}
RETVAL=$?
ERROR_MSG="blastadd.pl encountered an unknown error."
exit_if_error


if [ ! -e ${STRAND_IN_FILE} ]
then
	RETVAL=1
	ERROR_MSG="No sequences in the correct direction were found."
	DEBUG_MSG="The strand file does not exist."
	exit_if_error
fi

NUMSEQS=$(wc ${STRAND_IN_FILE} | awk '{print $1}')

if [ ! ${NUMSEQS} ] || [ ${NUMSEQS} -eq 0 ]
then
	RETVAL=1
	ERROR_MSG="No sequences in the correct direction were found."
	DEBUG_MSG="Number of sequences was 0."
	exit_if_error
else
	RETVAL=0
	NORMAL_MSG="${NUMSEQS} good sequences were found."
	exit_if_error
fi

# Store the number of sequences in a temporary file so that after the blasting
# has been completed we can compare it to the number of blasts.
echo "${NUMSEQS}" > ${NUMSEQS_TEMP_FILE}
RETVAL=$?
ERROR_MSG="Failed to write sequence count to ${NUMSEQS_TEMP_FILE}"
exit_if_error


#pulls match names
awk '{ print $1 }' ${STRAND_IN_FILE} > ${BLAST_INPUT_FILE}
RETVAL=$?
ERROR_MSG="Could not pull the matched names from strand file."
NORMAL_MSG="Successfully pulled the matched names from strand file."
DEBUG_MSG="Placed matched names in ${BLAST_INPUT_FILE}"
exit_if_error

# Split up the good sequence file
# Move into the BLAST_TEMP_DIR first, because that is where splitgood.pl
# places the new fasta files.
cd ${BLAST_TEMP_DIR}
echo "Splitting up the good sequence file."
${PERL_DIR}/splitgood.pl < ${GOOD_SEQUENCES_FILE}
RETVAL=$?
ERROR_MSG="Could not split up the good sequence file."
NORMAL_MSG="Successfully split the good sequences file."
DEBUG_MSG="Good sequences file: ${GOOD_SEQUENCES_FILE}"
exit_if_error

NORMAL_MSG="Successfully determined direction for blasting."
exit_success