#!/bin/bash
###########
# Takes 1 Variable
#	1. File that contains the good sequences  
# Returns 0 on success
###########

PERL_DIR="${1}"
WORKING_DIR="${2}"
BLAST_INPUT_FILE="${3}"
CUTOFF_LENGTH="${4}"


#BLASTPICKS="${PERL_DIR}blastpicks.pl"
#BLASTADD="${PERL_DIR}blastadd.pl"

STRAND_FILE="${WORKING_DIR}strands"
STRAND_IN_FILE="${WORKING_DIR}strandin"

$(${PERL_DIR}blastpicks.pl directionblast > ${STRAND_FILE})
$(${PERL_DIR}blastadd.pl ${CUTOFF_LENGTH} < ${STRAND_FILE} > ${STRAND_IN_FILE})

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

#pulls match names
$(awk  '{ print $1 }' ${STRAND_IN_FILE}  > ${BLAST_INPUT_FILE}) 
exit 0