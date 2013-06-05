#!/bin/bash
#####
# Requires:
#	PERL_DIR
#	OUTPUT_DIR
#	BLAST_DIR
#	REF_STRAINS_FILE
#	CLUSTAL_FILE
#	CLUSTAL_ALL_FILE
#	BLAST_INPUT_FILE
#	HIT_FILE


# Collate all the sequences into one file
# for clustal in FASTA format. 

# rm -f clustal
cd ${OUTPUT_DIR}
cat ${REF_STRAINS_FILE} > ${CLUSTAL_FILE}
echo "Collating all sequences"

for FILE in `cat ${BLAST_INPUT_FILE}`
  do
    cat ${BLAST_DIR}/$FILE >> ${CLUSTAL_FILE}
  done

for FILE in `cat ${HIT_FILE}`
  do
    cat ${BLAST_DIR}/$FILE >> ${CLUSTAL_FILE}
  done
  
# Give all the sequences a ten character ID which
# can be replaced with a real name later, otherwise
# the names are truncated by some of the following
# programs in a bad way!
echo "Shortening names to 10 characters"
${PERL_DIR}/nameshort.pl < {CLUSTAL_FILE} > ${CLUSTAL_ALL_FILE}