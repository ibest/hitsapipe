#!/bin/bash
###########
# Takes 1 Variable
#	1. File that contains the good sequences  
# Returns 0 on success
###########

GOOD_SEQUENCES_FILE="${1}"

# Format the good sequences into a database to blast against with our sample sequence
$(formatdb -i ${GOOD_SEQUENCES_FILE} -p F -o T)
exit $?