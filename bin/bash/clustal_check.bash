#!/bin/bash
#####
# Requires:
#	CLUSTAL_ALIGNMENT_FILE
#####

#Check that an alignment has been made
if [ ! -f ${CLUSTAL_ALIGNMENT_FILE} ]
 then
  echo "Cannot find ${CLUSTAL_ALIGNMENT_FILE}!"
  echo "ClustalW did not make an alignment!  Quitting."
  exit 1
fi
exit 0