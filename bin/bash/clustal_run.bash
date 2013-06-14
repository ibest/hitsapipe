#!/bin/bash
#####
# Requires:
#	CLUSTAL_ALL_FILE
#	CLUSTAL_ALIGNMNET_FILE
#####
echo "Running clustalw2"
echo -e "\tInput File: \t${CLUSTAL_ALL_FILE}"
echo -e "\tOutput File: \t${CLUSTAL_ALIGNMENT_FILE}"

RETVAL=$(clustalw2  -align -type=DNA -infile="${CLUSTAL_ALL_FILE}" -outfile="${CLUSTAL_ALIGNMENT_FILE}")$?

if [ ${RETVAL} != 0 ]
	then
		echo -e "\nERROR: Unknown clustalw2 error."
		echo -e "\tclustalw2 exit code: ${RETVAL}"
		exit 1
fi