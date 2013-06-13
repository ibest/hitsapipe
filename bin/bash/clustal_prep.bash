#!/bin/bash
#####
# Requires:
#	PERL_DIR
#	CLUSTAL_OUTPUT_DIR
#	BLAST_TEMP_DIR
#	ARRAY_OUTPUT_FILE
#	REF_STRAINS_FILE
#	CLUSTAL_FILE
#	CLUSTAL_ALL_FILE
#	BLAST_INPUT_FILE
#	HIT_FILE


# Collate all the sequences into one file
# for clustal in FASTA format. 

# rm -f clustal
echo "Collating all sequences"
cd ${CLUSTAL_OUTPUT_DIR}
cat ${REF_STRAINS_FILE} > ${CLUSTAL_FILE}


for FILE in `cat ${BLAST_INPUT_FILE}`
  do
    cat ${BLAST_TEMP_DIR}/${FILE} >> ${CLUSTAL_FILE}
  done

for FILE in `cat ${HIT_FILE}`
  do
    cat ${CLUSTAL_OUTPUT_DIR}/${FILE} >> ${CLUSTAL_FILE}
  done
  
# Give all the sequences a ten character ID which
# can be replaced with a real name later, otherwise
# the names are truncated by some of the following
# programs in a bad way!
echo "Shortening names to 10 characters"
${PERL_DIR}/nameshort.pl < ${CLUSTAL_FILE} > ${CLUSTAL_ALL_FILE}

# Now that we have a list of shortened names,
# lets take those files and append a unique
# identifier to them so that they may be submitted
# as an array job to qsub.

#ITER=0

#cd ${CLUSTAL_OUTPUT_DIR}

#for FILE in $(cat ${CLUSTAL_ALL_FILE})
#do
#	echo "mv "${FILE}" "${CLUSTAL_TEMP_DIR}/${FILE}.${ITER}""
#	mv "${FILE}" "${CLUSTAL_TEMP_DIR}/${FILE}.${ITER}"
#	((ITER++))
#done
#
#echo "${ITER}" > ${ARRAY_OUTPUT_FILE}