#!/bin/bash
EXITCODE=$(blastall -p blastn -d ${GOOD_SEQUENCES_FILE} -i ${BLAST_SEQUENCES} -S 1 -o ${DIRECTION_BLAST_FILE} -z 53,000,000 -b 10000)$?
exit $EXITCODE