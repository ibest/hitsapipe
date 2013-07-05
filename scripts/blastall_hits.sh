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
#	HIT_OUTPUT_DIR # Used to be called 8Fphylo
#	BLASTALL_OUTPUT_DIR
#	DATABASE
#	BLAST_OUT_5_FILE
#	HIT_SEQS_FILE
#	HIT_FILE
#####

if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###"
	echo -e "\tPERL_DIR: ${PERL_DIR}"
	echo -e "\tBLASTALL_OUTPUT_DIR: ${BLASTALL_OUTPUT_DIR}"
	echo -e "\tHIT_OUTPUT_DIR: ${HIT_OUTPUT_DIR}"
	echo -e "\tDATABASE: ${DATABASE}"
	echo -e "\tBLAST_OUT_5_FILE: ${BLAST_OUT_5_FILE}"
	echo -e "\tHIT_SEQS_FILE: ${HIT_SEQS_FILE}"
	echo -e "\tHIT_FILE: ${HIT_FILE}"
	echo -e "### DEBUG OUTPUT END ###"
fi

#all the individual blasts into one file
echo "Concatenating the blast file"
find ${BLASTALL_OUTPUT_DIR} -name "*.blastn" -print0 | xargs -i -0 cat {} > ${BLAST_OUT_5_FILE}

echo "Parsing blast results"
echo "blastparser cmd: ${PERL_DIR}/blastparser.pl ${BLAST_OUT_5_FILE} > ${HIT_OUTPUT_DIR}/output5.xls"
echo "blastcull cmd: ${PERL_DIR}/blastcull.pl < ${HIT_OUTPUT_DIR}/output5.xls > ${HIT_OUTPUT_DIR}/output1.xls"
${PERL_DIR}/blastparser.pl ${BLAST_OUT_5_FILE} > ${HIT_OUTPUT_DIR}/output5.xls
cd ${HIT_OUTPUT_DIR}
${PERL_DIR}/blastcull.pl < ${HIT_OUTPUT_DIR}/output5.xls > ${HIT_OUTPUT_DIR}/output1.xls

echo "Making hit spreadsheets."
cd ${HIT_OUTPUT_DIR}
cut -f3,4 output5.xls > ${HIT_OUTPUT_DIR}/hitnames_long5.xls
cut -f3,4 output1.xls > ${HIT_OUTPUT_DIR}/hitnames_long1.xls

echo "Making hit statistics."
echo "hit_statistics cmd: ${PERL_DIR}/hit_statistics.pl ${HIT_OUTPUT_DIR}/output1.xls ${HIT_OUTPUT_DIR}/hit_statistics.xls"
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