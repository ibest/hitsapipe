#!/bin/bash
#####
# Requires:
#	PERL_DIR
#	HIT_OUTPUT_DIR # Used to be called 8Fphylo
#	BLASTALL_OUTPUT_DIR
#	DATABASE
#	BLAST_OUT_5_FILE
#	HIT_SEQS_FILE
#	HIT_FILE
#####
echo "Debug start..."
echo "BLAST_OUT_5_FILE: ${BLAST_OUT_5_FILE}"
echo -e "Debug end...\n"

#all the individual blasts into one file
echo "Concatenating the blast file"
find ${BLASTALL_OUTPUT_DIR} -name "*.blastn" -print0 | xargs -i -0 cat {} > ${BLAST_OUT_5_FILE}

echo "Parsing blast results"
${PERL_DIR}/blastparser.pl ${BLAST_OUT_5_FILE} > ${HIT_OUTPUT_DIR}/output5.xls
cd ${HIT_OUTPUT_DIR}
${PERL_DIR}/blastcull.pl < ${HIT_OUTPUT_DIR}/output5.xls > ${HIT_OUTPUT_DIR}/output1.xls

echo "Making hit spreadsheets."
cd ${HIT_OUTPUT_DIR}
cut -f3,4 output5.xls > ${HIT_OUTPUT_DIR}/hitnames_long5.xls
cut -f3,4 output1.xls > ${HIT_OUTPUT_DIR}/hitnames_long1.xls

echo "Making hit statistics."
cd ${HIT_OUTPUT_DIR}
${PERL_DIR}/hit_statistics.pl ${HIT_OUTPUT_DIR}/output1.xls ${HIT_OUTPUT_DIR}/hit_statistics.xls

echo -e "Getting the unique hits:\n"
sort -u ${HIT_OUTPUT_DIR}/hitnames_long1.xls > ${HIT_OUTPUT_DIR}/hitnames
cat ${HIT_OUTPUT_DIR}/hitnames
echo -e "\n"

# Get a list of the lowercase IDs for the sequences.
# Also, make a list of the to-be filesnames for the sequences
awk '{print $1 }' ${HIT_OUTPUT_DIR}/hitnames | tr '[A-Z]' '[a-z]' > ${HIT_OUTPUT_DIR}/hitseqs1
sort ${HIT_OUTPUT_DIR}/hitseqs1 > ${HIT_SEQS_FILE}
rm ${HIT_OUTPUT_DIR}/hitseqs1 # Was just a temp file.
sed "s/$/.fasta/g" ${HIT_SEQS_FILE} > ${HIT_FILE}

# Copy the file from the database sequences folder to the blast directory
echo "Fetching the hit sequences from the database"
for NAME in `cat ${HIT_SEQS_FILE}`
	do 
    echo "Fetching ${DATABASE}:${NAME}"
    fastacmd -d ${DATABASE} -p F -s $NAME > ${HIT_OUTPUT_DIR}/${NAME}.fasta
		if [ ! -e $NAME.fasta ]
		then
			echo "WARNING:  Could not fetch $NAME.fasta!"
		fi
	done