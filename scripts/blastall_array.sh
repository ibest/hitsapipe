#!/bin/bash
#####
# Requires:
#	BLAST_TEMP_DIR: 			Directory where all of the good fasta files are
#	BLASTALL_OUTPUT_DIR: 		Directory to place the output files.
#	DATABASE: 					Database to blast against.
#	NHITS: 						
#####
# Additional:
#	TO_BLAST: 				The name of the file we are blasting
#	BLAST_OUTPUT_NAME: 		The output name of the file
#####

if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###"
	echo -e "\tBLAST_TEMP_DIR: ${BLAST_TEMP_DIR}"
	echo -e "\tBLASTALL_OUTPUT_DIR: ${BLASTALL_OUTPUT_DIR}"
	echo -e "\tDATABASE: ${DATABASE}"
	echo -e "\tNHITS: ${NHITS}"
	echo -e "\tARRAY_ID: ${PBS_ARRAYID}"
	echo -e "### DEBUG OUTPUT END ###"
fi

# Run find on the directory to find which file` we are supposed to blast.
# Then get its basename without the array id appended to it for saving the
# output from blastall.

TO_BLAST=$(find ${BLAST_TEMP_DIR} -maxdepth 1 -name "*.${PBS_ARRAYID}")
BLAST_OUTPUT_NAME=$(basename ${TO_BLAST%.*})
BLAST_OUTPUT_NAME=$(echo "${BLAST_OUTPUT_NAME}.blastn")

echo "Blasting file ${TO_BLAST} against the database ${DATABASE}"
echo -e "\tStoring the output in ${BLASTALL_OUTPUT_DIR}/${BLAST_OUTPUT_NAME}"

if [ ${EXECUTION} == "Parallel" ]
then
	DBNAME=$(echo "${DATABASE##*/}")  

	mpiexec -np ${NNODES} mpiblast -p blastn -d ${DBNAME}  -b ${NHITS} -v ${NHITS} -i "${TO_BLAST}" -S 1 -o "${BLASTALL_OUTPUT_DIR}/${BLAST_OUTPUT_NAME}" --removedb
	RETVAL=$?
	
	if [ ${RETVAL} != 0 ]
	then
		echo -e "\nERROR: mpiexec/mpiBLAST could not complete."
		echo -e "\tmpiexec exit code: ${RETVAL}"
		touch ${ERROR_FILE}
		exit 1
	fi
else
	blastall -p blastn -d ${DATABASE}  -b ${NHITS} -v ${NHITS} -i "${TO_BLAST}" -S 1 -o "${BLASTALL_OUTPUT_DIR}/${BLAST_OUTPUT_NAME}"
	RETVAL=$?
	
	if [ ${RETVAL} != 0 ]
	then
		echo -e "\nERROR: Blastall could not complete."
		echo -e "\tblastall exit code: ${RETVAL}"
		touch ${ERROR_FILE}
		exit 1
	fi
fi


# Finally, change the name back of this file
echo "Blast successful. Removing PBS array file extension."
RENAME=$(echo "${TO_BLAST%.*}")
mv ${TO_BLAST} ${RENAME}
RETVAL=$?
exit ${RETVAL}