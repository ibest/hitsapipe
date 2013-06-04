#!/bin/bash
STRAND_FILE="${PBS_O_WORKDIR}/strands"
STRAND_IN_FILE="${PBS_O_WORKDIR}/strandin"

${PERL_DIR}/blastpicks.pl ${DIRECTION_BLAST_FILE} > ${STRAND_FILE}
${PERL_DIR}/blastadd.pl ${CUTOFF_LENGTH} < ${STRAND_FILE} > ${STRAND_IN_FILE}

if [ ! -e ${STRAND_IN_FILE} ]
then
	echo "Error: No sequences in the right direction found. Exiting."
	exit 1
fi

NUMSEQS=$(wc ${STRAND_IN_FILE} | awk '{print $1}')

if [ ! ${NUMSEQS} ] || [ ${NUMSEQS} -eq 0 ]
then
	echo "Error: No sequences in the right direction found. Exiting."
	exit 1
else
	echo "${NUMSEQS} good sequences were found."
fi

#pulls match names
awk '{ print $1 }' ${STRAND_IN_FILE} > ${BLAST_INPUT_FILE} 
exit 0