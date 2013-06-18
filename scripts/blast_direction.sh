#!/bin/bash
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
#####
# Additional:
#	NUMSEQS: 				Number of good sequences that are found.
#	STRAND_IN_FILE: 		Temporary file for blastpicks/blastadd.
#	STRAND_FILE: 			Temporary file for blastpicks/blastadd.
#	MPINODES: 				If parallel, how many nodes mpiformatdb should use.
#####

if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###"
	echo -e "\tPERL_DIR: ${PERL_DIR}"
	echo -e "\tLOG_DIR: ${LOG_DIR}"
	echo -e "\tBLAST_TEMP_DIR: ${BLAST_TEMP_DIR}"
	echo -e "\tGOOD_SEQUENCES_FILE: ${GOOD_SEQUENCES_FILE}"
	echo -e "\tDIRECTION_BLAST_FILE: ${DIRECTION_BLAST_FILE}"
	echo -e "\tBLAST_INPUT_FILE: ${BLAST_INPUT_FILE}"
	echo -e "\tNUMSEQS_TEMP_FILE: ${NUMSEQS_TEMP_FILE}"
	echo -e "\tBLAST_SEQUENCES: ${BLAST_SEQUENCES}"
	echo -e "\tCUTOFF_LENGTH: ${CUTOFF_LENGTH}"
	echo -e "### DEBUG OUTPUT END ###"
fi


# Format the good sequences into a database to blast against 
# with our sample sequence.
# If this is to be run in parallel, call mpiformatdb
# If not, call formatdb

if [ ${PARALLEL} == "True" ]
then
	MPINODES=$((NNODES - 2))
	echo "Running mpiformatdb to format the good sequences into a database to blast against with out sample sequence."
	mpiformatdb -N ${MPINODES} -i ${GOOD_SEQUENCES_FILE} -p F -o T -l ${LOG_DIR}/formatdb.log
	RETVAL=$?
	
	if [ ${RETVAL} != 0 ]
	then
		echo -e "\nERROR: Unknown mpiformatdb error."
		echo -e "\tmpiformatdb exit code: ${RETVAL}"
		exit 1
	fi
else
	echo "Running formatdb to format the good sequences into a database to blast against with our sample sequence."
	
	EXITCODE=$(formatdb -i ${GOOD_SEQUENCES_FILE} -p F -o T -l ${LOG_DIR}/formatdb.log)$?
	
	if [ ${EXITCODE} != 0 ]
		then
			echo -e "\nERROR: Unknown formatdb error."
			echo -e "\tformatdb exit code: ${EXITCODE}"
			exit 1
	fi
fi

if [ ${PARALLEL} == "True" ]
then
	echo -e "\nBLASTing ${BLAST_SEQUENCES} against sequences to find direction."
	mpiexec -N ${NNODES} mpiblast -p blastn -d ${GOOD_SEQUENCES_FILE} -i ${BLAST_SEQUENCES} -S 1 -o ${DIRECTION_BLAST_FILE} -z 53,000,000 -b 10000 
	RETVAL=$?
	
	if [ ${RETVAL} != 0 ]
	then
		echo -e "\nERROR: Unknown mpiexec/mpiblast error."
		echo -e "\tmpiexec exit code: ${RETVAL}"
		exit 1
	fi

else
	echo -e "\nBLASTing ${BLAST_SEQUENCES} against sequences to find direction."
	EXITCODE=$(blastall -p blastn -d ${GOOD_SEQUENCES_FILE} -i ${BLAST_SEQUENCES} -S 1 -o ${DIRECTION_BLAST_FILE} -z 53,000,000 -b 10000)$?
	
	if [ ${EXITCODE} != 0 ]
		then
			echo -e "\nERROR: blastall could not finish."
			echo -e "\tblastall exit code: ${EXITCODE}"
			exit 1
	fi
fi




STRAND_FILE="${BLAST_TEMP_DIR}/strands"
STRAND_IN_FILE="${BLAST_TEMP_DIR}/strandin"

${PERL_DIR}/blastpicks.pl ${DIRECTION_BLAST_FILE} > ${STRAND_FILE}
${PERL_DIR}/blastadd.pl ${CUTOFF_LENGTH} < ${STRAND_FILE} > ${STRAND_IN_FILE}

if [ ! -e ${STRAND_IN_FILE} ]
then
	echo "Error: No sequences in the right direction found. Exiting."
	exit 1
fi

NUMSEQS=$(wc ${STRAND_IN_FILE} | awk '{print $1}')

if [ ! ${NUMSEQS} ] || [ ${NUMSEQS} -eq 0 ]
then
	echo "Error: No sequences in the right direction found. Exiting."
	exit 1
else
	echo "${NUMSEQS} good sequences were found."
fi

# Store the number of sequences in a temporary file so that after the blasting
# has been completed we can compare it to the number of blasts.
echo "${NUMSEQS}" > ${NUMSEQS_TEMP_FILE}


#pulls match names
echo "Pulling match names and placing in ${BLAST_INPUT_FILE}"
awk '{ print $1 }' ${STRAND_IN_FILE} > ${BLAST_INPUT_FILE} 

# Split up the good sequence file
# Move into the BLAST_TEMP_DIR first, because that is where splitgood.pl
# places the new fasta files.
cd ${BLAST_TEMP_DIR}
echo "Splitting up the good sequence file."
EXITCODE=$(${PERL_DIR}/splitgood.pl < ${GOOD_SEQUENCES_FILE})$?

if [ ${EXITCODE} != 0 ]
	then
		echo -e "\nERROR: Could not split up the good sequence file."
		echo -e "\tsplitgood.pl exit code: ${EXITCODE}"
		exit 1
fi



exit 0