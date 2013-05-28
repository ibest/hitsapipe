#!/bin/bash
###########
# Takes 5 variables:
#	1.  The directory with the sequences
#	2.  The perl script directory
#	3.  The the location of where to store the list
#	4.  The directory of where to place the originals (backups).
#	5.  The file extension of the sequence files
#
# Returns 0 on success
###########

SEQUENCE_DIR="$1"
PERL_DIR="$2"
LIST_FILE="$3"
BACKUP_DIR="$4"
SUFFIX="$5"

echo "Collating all ${SUFFIX} files into list"
find $SEQUENCE_DIR -maxdepth 1 -name "*$SUFFIX" -exec basename {} \; > $LIST_FILE

## Windows/Mac endlines to Unix endlines
echo "Ensuring Unix endlines on all files"
for FILE in $(cat ${LIST_FILE}) #`cat $LIST_FILE`
  do
    perl -p -i.orig -e 's/\r\n|\r/\n/g' ${SEQUENCE_DIR}${FILE}
  done

#back up original files.
echo "Backing up original sequences"
find ${SEQUENCE_DIR} -maxdepth 1 -name "*.orig" -print0 | xargs -i -0 mv {} ${BACKUP_DIR}

#With suffix denoting the suffix of the sequence FASTA files,
#changes their FASTA names to their filenames 
echo "Making sure all filenames are the FASTA sequences names"
CURR_DIR=$(pwd)
cd ${SEQUENCE_DIR}
$(${PERL_DIR}namechange.pl ${SUFFIX})
cd ${CURR_DIR}
# Finally, return the exit status of namechange.pl
exit $?