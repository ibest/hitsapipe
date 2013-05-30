#!/bin/bash
###########
# Takes 1 Variable
#	1. File that contains the good sequences  
# Returns 0 on success
###########

PERL_DIR="${1}"
GOOD_SEQUENCES_FILE="${2}"

$(echo "splitgood.pl: Splitting up ${GOOD_SEQUENCES_FILE}")
$(${PERL_DIR}splitgood.pl < ${GOOD_SEQUENCES_FILE})
exit $?