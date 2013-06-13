#!/bin/bash
# Given the number of arrays and the base id,
# check to see if all of the array jobs have
# finished, and if they haven't, sleep for 10
# seconds and then check again.
# For simplicity, pass in one less than the
# array count for looping (i.e. the index of 
# the last item).

ID=${1}
ARR_COUNT=${2}
while(true)
do
	for i in $(seq 0 ${ARR_COUNT})
	do
		RETOUT=$(qstat -f ${ID}[${i}] | awk '/job_state = C/' -)
		RETVAL=$(qstat -f ${ID}[${i}] | awk '/job_state = C/' -)$?
		echo "For ${ID}[${i}]:"
		echo -e "\tRETOUT: ${RETOUT}"
		echo -e "\tRETVAL: ${RETVAL}"
		sleep 2
	done
	sleep 5
done