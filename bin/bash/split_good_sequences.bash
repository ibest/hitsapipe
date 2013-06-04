#!/bin/bash
echo "Splitting the good sequences file: ${GOOD_SEQUENCES_FILE}"
EXITCODE=$(${PERL_DIR}/splitgood.pl ${PBS_O_WORKDIR} < ${GOOD_SEQUENCES_FILE})$?
exit $EXITCODE