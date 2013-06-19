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

if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###"
	echo -e "\tPERL_DIR: ${PERL_DIR}"
	echo -e "\tCLUSTAL_OUTPUT_DIR: ${CLUSTAL_OUTPUT_DIR}"
	echo -e "\tBLAST_TEMP_DIR: ${BLAST_TEMP_DIR}"
	echo -e "\tARRAY_OUTPUT_FILE: ${ARRAY_OUTPUT_FILE}"
	echo -e "\tREF_STRAINS_FILE: ${REF_STRAINS_FILE}"
	echo -e "\tCLUSTAL_FILE: ${CLUSTAL_FILE}"
	echo -e "\tCLUSTAL_ALL_FILE: ${CLUSTAL_ALL_FILE}"
	echo -e "\tBLAST_INPUT_FILE: ${BLAST_INPUT_FILE}"
	echo -e "\tHIT_FILE: ${HIT_FILE}"
	echo -e "### DEBUG OUTPUT END ###"
fi

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
cd ${CLUSTAL_OUTPUT_DIR}
echo "Shortening names to 10 characters"
echo "nameshort cmd: ${PERL_DIR}/nameshort.pl < ${CLUSTAL_FILE} > ${CLUSTAL_ALL_FILE}"
${PERL_DIR}/nameshort.pl < ${CLUSTAL_FILE} > ${CLUSTAL_ALL_FILE}