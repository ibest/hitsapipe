#!/bin/bash
# pipeline_prep.sh
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This script copies the references file and blast sequences file
# and places them in the backup directory.
##########

# Grab the helper functions to get
# generate the correct filenames for 
# HiTSAPipe's error checking.
source ${HELPER_FUNCTIONS}

SUCCESS_FILE=$(get_success)
FAILURE_FILE=$(get_failure)

#echo "Loading required modules..."
#module load ncbi clustalw phylip emboss perl openmpi openmpi-apps
#RETVAL=$?
#ERROR_MSG="Cannot load all of the modules."
#exit_if_error

echo "Copying the reference strains to backup directory..."
cp ${REFERENCE_STRAINS} ${REFERENCES_DIR}/
RETVAL=$?
ERROR_MSG="Cannot copy reference strains file."
exit_if_error

echo "Copying the blast sequences to backup directory..."
cp ${BLAST_SEQUENCES} ${REFERENCES_DIR}/
RETVAL=$?
ERROR_MSG="Cannot copy blast sequences file."
exit_if_error

# If everything went well, call exit
exit_success