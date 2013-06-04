#!/bin/bash
#####
# Requires:
#	PERL_DIR
#	OUTPUT_DIR
#####

echo "Changing back to full names"
EXITCODE=$(${PERL_DIR}/namesback.pl $OUTPUT_DIR)$?
exit ${EXITCODE}