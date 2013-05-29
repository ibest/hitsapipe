#!/bin/bash
###########
# Takes 1 Variable
#	1. File that contains the good sequences  
# Returns 0 on success
###########

GOOD_SEQUENCES_FILE="${1}"
BLAST_SEQUENCES="${2}"

$(blastall -p blastn -d ${GOOD_SEQUENCES_FILE} -i ${BLAST_SEQEUNCES} -S 1 -o directionblast -z 53,000,000 -b 10000)
exit $?