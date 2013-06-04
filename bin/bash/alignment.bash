#!/bin/bash
#####
# Requires:
#	PERL_DIR
#	OUTPUT_DIR
#	CLUSTAL_ALIGNMENT_FILE
#	IN_FILE
#####

# Find the alignment start and end
echo "Getting alignment start and end"
${PERL_DIR}/findalign.pl < ${CLUSTAL_ALIGNMENT_FILE} > ${OUTPUT_DIR}/alignmentpoints

#gets start and end from a file
START=${START:-$(awk '/START/ {print $2}' ${OUTPUT_DIR}/alignmentpoints)}
#'
END=${END:-$(awk '/END/ {print $2}' ${OUTPUT_DIR}/alignmentpoints)}
#'

echo "START: $START"
echo "END: $END"

cd ${OUTPUT_DIR}

#Clipping the alignment file to the start and end, converting to phylip format
echo "Clipping the alignment"
seqret -sbegin $START -send $END clustal::${CLUSTAL_ALIGNMENT_FILE} phylip::${CLUSTAL_PHYLIP_FILE}

${PERL_DIR}/convert_clustal_to_phylip.pl < ${CLUSTAL_PHYLIP_FILE} > ${IN_FILE}

#remove any file named outfile -- dnadist won't know what to do
rm -rf outfile