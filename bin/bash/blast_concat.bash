#!/bin/bash
#####
# Requires:
#	BLAST_OUTPUT_DIR
#	BLAST_OUT_5_DIR
#####
EXITCODE=$(find ${BLAST_OUTPUT_DIR} -maxdepth 1 -name "*.blastn" -print0 | xargs -i -0 cat {} >> ${BLAST_OUT_5_DIR})$?
exit ${EXITCODE}