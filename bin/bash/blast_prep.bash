#!/bin/bash
###########
# Takes 1 Variable
#	1. File that contains the good sequences  
# Returns 0 on success
###########

BLAST_OUTPUT_DIR="${1}"

$(mkdir BLAST_OUTPUT_DIR)
exit $?