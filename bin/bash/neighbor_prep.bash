#!/bin/bash
#####
# Requires:
#	PERL_DIR
#	NEIGHBOR_DIR
#	NEIGHBOR_ROOT
#####

# Make a script for neighbor based on the root we give
EXITCODE=$(${PERL_DIR}/makeneighbor.pl ${NEIGHBOR_DIR} ${NEIGHBOR_ROOT} ${PERL_DIR} ${PERL_DIR}/searchnames.pl)$?
exit ${EXITCODE}