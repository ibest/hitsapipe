#!/bin/bash
#####
# Requires:
#	CLUSTAL_ALIGNMENT_FILE
#####

if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###"
	echo -e "\tCLUSTAL_ALIGNMENT_FILE: ${CLUSTAL_ALIGNMENT_FILE}"
	echo -e "### DEBUG OUTPUT END ###"
fi

#Check that an alignment has been made
if [ ! -f ${CLUSTAL_ALIGNMENT_FILE} ]
 then
  echo "Cannot find ${CLUSTAL_ALIGNMENT_FILE}!"
  echo "ClustalW did not make an alignment!  Quitting."
  exit 1
fi
exit 0