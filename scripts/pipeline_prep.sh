#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

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