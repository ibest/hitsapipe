#!/bin/bash
###########
# Takes N variables
#	1.  The directory with the sequences
#	2.  The perl script directory
#	3.  The file to store the list of input sequences for processing
#	4.  The directory for blast files
#	5.  The fasta file file extension
#	6.  The direction of the sequences
#
# Returns 0 on success
###########

SEQUENCE_DIR="$1"
PERL_DIR="$2"
INPUT_SEQUENCES_FILE="$3"
BLAST_DIR="$4"
SUFFIX="$5"
DIRECTION="$6"

GOOD_SEQUENCES_FILE="${BLAST_DIR}good_sequences"


echo "Collating sequences..."
find ${SEQEUNCE_DIR} -maxdepth 1 -name "*${SUFFIX}" -print0 | xargs -i -0 cat {} >> ${INPUT_SEQUENCES_FILE}

echo "Finding the good seqs and placing them in ${GOOD_SEQUENCES_FILE}"

#This part tries to figure out whether a sequence is valid --
#make the percentage cutoff for countN2 a parameter and whether to do this
#a parameter as well
$(${PERL_DIR}countN2.pl) $NPERCENT $PRIMER3 $PRIMER5 $MINSEQLENGTH < ${INPUT_SEQUENCES_FILE} > ${GOOD_SEQUENCES_FILE}

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
     mv ${GOOD_SEQUENCES_FILE} ${BLAST_DIR}beforereverse
     mv ${BLASTDIR}revseqs ${GOOD_SEQUENCES_FILE}
esac

if [ ! -e ${GOOD_SEQUENCES_FILE} ]
then
  echo "No good sequences found!  Exiting."
	exit 1
fi

exit $?