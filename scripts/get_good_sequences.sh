#!/bin/bash
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
	echo -e "### DEBUG OUTPUT START ###"
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
	echo -e "### DEBUG OUTPUT END ###"
fi

echo "Collating sequences..."
find ${INPUT_SEQUENCES} -maxdepth 1 -name "*${SUFFIX}" -print0 | xargs -i -0 cat {} >> ${INPUT_SEQUENCES_FILE}

echo "Finding the good seqs and placing them in ${GOOD_SEQUENCES_FILE}"

#This part tries to figure out whether a sequence is valid --
#make the percentage cutoff for countN2 a parameter and whether to do this
#a parameter as well

cd ${INPUT_SEQUENCES}
${PERL_DIR}/countN2.pl ${NPERCENT} ${PRIMER3} ${PRIMER5} ${MIN_SEQUENCE_LENGTH} < ${INPUT_SEQUENCES_FILE} > ${GOOD_SEQUENCES_FILE}
cd ${PBS_O_WORKDIR}

if [ ! -e ${GOOD_SEQUENCES_FILE} ] || [ ! -s ${GOOD_SEQUENCES_FILE} ]
then
	echo "No good sequences found!  Exiting."
	touch ${ERROR_FILE}
	exit 1
fi

#If our direction is REVERSE, then we will reverse the sequences within
#goodseqs and replace it with the reversed sequences
case ${DIRECTION} in
   REVERSE|reverse|R|r)
     echo "Reverse orientation, reversing sequences"
     seqret -srev -sequence ${GOOD_SEQUENCES_FILE} -offormat2 fasta -outseq revseqs -auto
     mv ${GOOD_SEQUENCES_FILE} ${BLAST_DIR}/beforereverse
     mv ${BLASTDIR}/revseqs ${GOOD_SEQUENCES_FILE}
esac

if [ ! -e ${GOOD_SEQUENCES_FILE} ] || [ ! -s ${GOOD_SEQUENCES_FILE} ]
then
	echo "No good sequences found after reversing!  Exiting."
	touch ${ERROR_FILE}
	exit 1
fi

exit 0