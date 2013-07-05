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
#	PERL_DIR
#	CLUSTAL_OUTPUT_DIR
#	CLUSTAL_ALIGNMENT_FILE
#	PHYLIP_IN_FILE
#####

if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###"
	echo -e "\tPERL_DIR: ${PERL_DIR}"
	echo -e "\tCLUSTAL_OUTPUT_DIR: ${CLUSTAL_OUTPUT_DIR}"
	echo -e "\tCLUTAL_ALIGNMENT_FILE: ${CLUSTAL_ALIGNMENT_FILE}"
	echo -e "\tPHYLIP_IN_FILE: ${PHYLIP_IN_FILE}"
	echo -e "### DEBUG OUTPUT END ###"
fi

CLUSTAL_PHYLIP_FILE="${CLUSTAL_OUTPUT_DIR}/clustal_all.phy"


# Find the alignment start and end
echo "Getting alignment start and end"
${PERL_DIR}/findalign.pl < ${CLUSTAL_ALIGNMENT_FILE} > ${CLUSTAL_OUTPUT_DIR}/alignmentpoints

#gets start and end from a file
START=${START:-$(awk '/START/ {print $2}' ${CLUSTAL_OUTPUT_DIR}/alignmentpoints)}
#'
END=${END:-$(awk '/END/ {print $2}' ${CLUSTAL_OUTPUT_DIR}/alignmentpoints)}
#'

echo "START: $START"
echo "END: $END"

cd ${CLUSTAL_OUTPUT_DIR}

#Clipping the alignment file to the start and end, converting to phylip format
echo "Clipping the alignment"
seqret -sbegin $START -send $END clustal::${CLUSTAL_ALIGNMENT_FILE} phylip::${CLUSTAL_PHYLIP_FILE}

${PERL_DIR}/convert_clustal_to_phylip.pl < ${CLUSTAL_PHYLIP_FILE} > ${PHYLIP_IN_FILE}

#remove any file named outfile -- dnadist won't know what to do
rm -rf outfile