#!/bin/bash
###########
# Takes 11 variables
#	1.  The directory with the sequences
#	2.  The perl script directory
#	3.  The file to store the list of input sequences for processing
#	4.  The directory for blast files
#	5.  The fasta file file extension
#	6.  The direction of the sequences
#	7.  The percentage of Ns allowed before failing
#	8.  Primer on the 3' end
#	9.  Primer of the 5' end
#	10. Minimum length needed for a sequence to be accepted
#	11. The file to store the good sequences in
#
# Returns 0 on success
###########

# Debugging
#echo "==================================================="
#echo "GOOD SEQUENCES BASH SCRIPT - PRINTING VARIABLES"
#echo "==================================================="
#echo "${SEQUENCE_DIR}"
#echo "${PERL_DIR}"
#echo "${INPUT_SEQUENCES_FILE}"
#echo "${BLAST_DIR}"
#echo "${SUFFIX}"
#echo "${DIRECTION}"
#echo "${NPERCENT}"
#echo "${PRIMER3}"
#echo "${PRIMER5}"
#echo "${MINSEQLENGTH}"
#echo "${GOOD_SEQUENCES_FILE}"
#echo "==================================================="


echo "Collating sequences..."
find ${SEQUENCE_DIR} -maxdepth 1 -name "*${SUFFIX}" -print0 | xargs -i -0 cat {} >> ${INPUT_SEQUENCES_FILE}

echo "Finding the good seqs and placing them in ${GOOD_SEQUENCES_FILE}"

#This part tries to figure out whether a sequence is valid --
#make the percentage cutoff for countN2 a parameter and whether to do this
#a parameter as well
CURR_DIR=$(pwd)
cd ${SEQUENCE_DIR}
${PERL_DIR}/countN2.pl ${NPERCENT} ${PRIMER3} ${PRIMER5} ${MINSEQLENGTH} < ${INPUT_SEQUENCES_FILE} > ${GOOD_SEQUENCES_FILE}
cd ${CURR_DIR}

if [ ! -e ${GOOD_SEQUENCE_FILE} ]
then
  echo "No good sequences found!  Exiting."
	exit 1
fi

if [ ! -s ${GOOD_SEQEUNCE_FILE} ]
then
  echo "No good sequences found!  Exiting."
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

if [ ! -e ${GOOD_SEQUENCES_FILE} ]
then
  echo "No good sequences found!  Exiting."
	exit 1
fi
#exit $0