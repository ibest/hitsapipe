#!/bin/bash
#####
# Requires:
#	NEIGHBOR_DIR
#	NEIGHBOR_SCRIPT
#####

# Generate the final tree given neighbor_script, which was created
# by makeneighbor.pl
cd ${NEIGHBOR_DIR}
echo "Making the tree"
EXITCODE=$(neighbor < ${NEIGHBOR_SCRIPT})$?
exit ${EXITCODE}