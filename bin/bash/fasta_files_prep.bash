#!/bin/bash
#####
# Requires:
#	SEQUENCE_DIR: 			The directory with the sequences
#	PERL_DIR: 				The perl script directory
#	ORIGINALS_DIR: 			The directory of where to place the originals (backups).
#	INPUT_SEQUENCE_LIST: 	The the location of where to store the list
#	SUFFIX: 				The file extension of the sequence files
#####

echo "Collating all ${SUFFIX} files into list"
find ${SEQUENCE_DIR} -maxdepth 1 -name "*$SUFFIX" -exec basename {} \; > ${INPUT_SEQUENCE_LIST}

## Windows/Mac endlines to Unix endlines
echo "Ensuring Unix endlines on all files"
for FILE in $(cat ${INPUT_SEQUENCE_LIST})
  do
    perl -p -i.orig -e 's/\r\n|\r/\n/g' ${SEQUENCE_DIR}/${FILE}
  done

#back up original files.
echo "Backing up original sequences."
find ${SEQUENCE_DIR} -maxdepth 1 -name "*.orig" -print0 | xargs -i -0 mv {} ${ORIGINALS_DIR}

#With suffix denoting the suffix of the sequence FASTA files,
#changes their FASTA names to their filenames 
echo "Making sure all filenames are the FASTA sequences names."
cd ${SEQUENCE_DIR}
EXITCODE=$(${PERL_DIR}/namechange.pl ${SUFFIX})$?
cd ${PBS_O_WORKDIR}

if [ ${EXITCODE} != 0 ]
	then
		echo "ERROR: Filenames could not be change to FASTA sequence names. Exiting."
fi

exit ${EXITCODE}