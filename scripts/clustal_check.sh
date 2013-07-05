#!/bin/bash

# ***** BEGIN LICENSE BLOCK *****
# Version: MPL 1.1
#
# The contents of this file are subject to the Mozilla Public License Version
# 1.1 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
#
# Contributor(s):
#
# ***** END LICENSE BLOCK *****

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
  echo "ClustalW did not make an alignment!  Exiting."
  touch {ERROR_FILE}
  exit 1
fi
exit 0