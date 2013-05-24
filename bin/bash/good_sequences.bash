#!/bin/bash
###########
# Takes N variables
#	1.  The directory with the sequences
#	2.  The perl script directory
#	3.  The file to store the list of input sequences for processing
#	4.  The file to store the list of good sequences
#	5.  The fasta file file extension
#
# Returns 0 on success
###########

SEQUENCE_DIR="$1"
PERL_DIR="$2"
INPUT_SEQUENCES_FILE="$3"
GOOD_SEQUENCES_FILE="$4"
$SUFFIX="$5"

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

exit $?