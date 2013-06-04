#!/bin/bash
#####
# Requires:
#	PERL_DIR
#	OUTPUT_DIR # Used to be called 8Fphylo
#	DATABASE
#	BLAST_OUT_5_FILE
#	HIT_SEQS_FILE
#	HIT_FILE
#####

echo "Parsing blast results"
${PERL_DIR}/blastparser.pl ${BLAST_OUT_5_FILE} > ${OUTPUT_DIR}/output5.xls
cd ${OUTPUT_DIR}
${PERL_DIR}/blastcull.pl < output5.xls > output1.xls

echo "Making hit spreadsheets."
cd ${OUTPUT_DIR}
cut -f3,4 output5.xls > hitnames_long5.xls
cut -f3,4 output1.xls > hitnames_long1.xls

echo "Making hit statistics."
cd ${OUTPUT_DIR}
${PERL_DIR}/hit_statistics.pl output1.xls hit_statistics.xls

echo -e "Getting the unique hits:\n"
sort -u hitnames_long1.xls > ${OUTPUT_DIR}/hitnames
cat ${OUTPUT_DIR}/hitnames
echo -e "\n"

# Get a list of the lowercase IDs for the sequences.
# Also, make a list of the to-be filesnames for the sequences
awk '{print $1 }' ${OUTPUT_DIR}/hitnames | tr '[A-Z]' '[a-z]' > ${OUTPUT_DIR}/hitseqs1
sort ${OUTPUT_DIR}/hitseqs1 > ${HIT_SEQS_FILE}
rm ${OUTPUT_DIR}/hitseqs1 # Was just a temp file.
sed "s/$/.fasta/g" ${HIT_SEQS_FILE} > ${HIT_FILE}

# Copy the file from the database sequences folder to the blast directory
echo "Fetching the hit sequences from the database"
for NAME in `cat ${HIT_SEQS_FILE}`
	do 
    echo "Fetching ${DATABASE}:${NAME}"
    fastacmd -d ${DATABASE} -p F -s $NAME > ${OUTPUT_DIR}/${NAME}.fasta
		if [ ! -e $NAME.fasta ]
		then
			echo "WARNING:  Could not fetch $NAME.fasta!"
		fi
	done