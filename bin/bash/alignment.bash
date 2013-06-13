#!/bin/bash
#####
# Requires:
#	PERL_DIR
#	CLUSTAL_OUTPUT_DIR
#	CLUSTAL_ALIGNMENT_FILE
#	PHYLIP_IN_FILE
#####

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