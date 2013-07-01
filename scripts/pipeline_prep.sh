#!/bin/bash
#####
# Requires:
#	REFERENCE_STRAINS: 			RefStrains File from config file
#	BLAST_SEQUENCES: 			Blast Sequences from config file
#	REFERENCES_DIR: 			Backup directory
#####

echo "Copying the reference strains and blast sequences to backup directory."
if [ ${DEBUG} == "True" ]
	then
		echo "cp ${REFERENCE_STRAINS} ${REFERENCES_DIR}/"
		echo "cp ${BLAST_SEQUENCES} ${REFERENCES_DIR}/"
fi

cp ${REFERENCE_STRAINS} ${REFERENCES_DIR}/
cp ${BLAST_SEQUENCES} ${REFERENCES_DIR}/