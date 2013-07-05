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
#	DNADIST_SCRIPT
#	CLUSTAL_OUTPUT_DIR
#	DISTANCES_FILE
#	PHYLIP_IN_FILE
#####

if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###"
	echo -e "\tDNADIST_SCRIPT: ${DNADIST_SCRIPT}"
	echo -e "\tCLUSTAL_OUTPUT_DIR: ${CLUSTAL_OUTPUT_DIR}"
	echo -e "\tDISTANCES_FILE: ${DISTANCES_FILE}"
	echo -e "\tPHYLIP_IN_FILE: ${PHYLIP_IN_FILE}"
	echo -e "### DEBUG OUTPUT END ###"
fi

# Use dnadist to create the distance matrix.
# Then, move the file it creates where we want it to be
# Then, rename the IN_FILE so that the next script doesn't have
# any issues.

cd ${CLUSTAL_OUTPUT_DIR}
echo "Making the distance matrix..."
dnadist < ${DNADIST_SCRIPT}
mv outfile ${DISTANCES_FILE}
mv "${PHYLIP_IN_FILE}" "${PHYLIP_IN_FILE}.dnadist"