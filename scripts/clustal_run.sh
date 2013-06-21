#!/bin/bash
#####
# Requires:
#	CLUSTAL_ALL_FILE
#	CLUSTAL_ALIGNMNET_FILE
#####

if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###"
	echo -e "\tCLUSTAL_ALL_FILE: ${CLUSTAL_ALL_FILE}"
	echo -e "\tCLUSTAL_ALIGNMENT_FILE: ${CLUSTAL_ALIGNMENT_FILE}"
	echo -e "### DEBUG OUTPUT END ###"
fi

echo "Running clustalw2"
#if [ ${PARALLEL} == "True" ]
#then
#	echo "mpiexec/clustalw-mpi cmd: mpiexec -np ${NNODES} clustalw-mpi -align -type=DNA -infile="${CLUSTAL_ALL_FILE}" -outfile="${CLUSTAL_ALIGNMENT_FILE}""
#	mpiexec -np ${NNODES} clustalw-mpi -align -type=DNA -infile="${CLUSTAL_ALL_FILE}" -outfile="${CLUSTAL_ALIGNMENT_FILE}"
#		RETVAL=$?
#	
#	if [ ${RETVAL} != 0 ]
#		then
#			echo -e "\nERROR: clustalw-mpi could not complete."
#			echo -e "\tclustalw-mpi exit code: ${RETVAL}"
#			touch {ERROR_FILE}
#			exit 1
#	fi
#else
#	echo "clustalw2 cmd: clustalw2 -align -type=DNA -infile="${CLUSTAL_ALL_FILE}" -outfile="${CLUSTAL_ALIGNMENT_FILE}""
	clustalw2 -align -type=DNA -infile="${CLUSTAL_ALL_FILE}" -outfile="${CLUSTAL_ALIGNMENT_FILE}"
	RETVAL=$?
	
	if [ ${RETVAL} != 0 ]
		then
			echo -e "\nERROR: Unknown clustalw2 error."
			echo -e "\tclustalw2 exit code: ${RETVAL}"
			touch {ERROR_FILE}
			exit 1
	fi
#fi