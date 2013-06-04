BASEFILENAME=$(find ${BLAST_FASTA_DIR} -name "*.${PBS_ARRAYID} | cut -d'.' -f1)
echo "BASEFILENAME: $BASEFILENAME"
#blastall -p blastn -d ${DATABASE} -b {NHITS} -v ${NHITS} -i ${BLAST_FASTA_DIR}/*{SUFFIX}.${PBS_ARRAY_ID} -S 1 -o ${BLAST_OUTPUT}/