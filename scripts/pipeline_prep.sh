#!/bin/bash
# pipeline_prep.sh
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This script makes sure that all the required programs
# can be found on the system before trying to run the
# entire pipeline.
#
# Required programs:
#	seqret
#	neighbor
#	dnadist
#	
# Required standalone programs:
#	blastall
#	clustalw2 -- clustalw is a symlink to clustalw2
#
# Required parallel programs:
#	mpiformatdb
#	mpiexec
#	mpiblast
#	clustalw-mpi
#	
##########

# Grab the helper functions to get
# generate the correct filenames for 
# HiTSAPipe's error checking.
source ${HELPER_FUNCTIONS}

SUCCESS_FILE=$(get_success)
FAILURE_FILE=$(get_failure)

# Checking required programs
which seqret > /dev/null
RETVAL=$?
ERROR_MSG="seqret could not be found on the system."
DEBUG_MSG="seqret was found."
exit_if_error

which dnadist > /dev/null
RETVAL=$?
ERROR_MSG="dnadist could not be found on the system."
DEBUG_MSG="dnadist was found."
exit_if_error

which neighbor > /dev/null
RETVAL=$?
ERROR_MSG="neighbor could not be found on the system."
DEBUG_MSG="neighbor was found."
exit_if_error

# Checking required standalone programs
if [ "${EXECUTION}" != "Parallel" ]
	then

		which blastall > /dev/null
		RETVAL=$?
		ERROR_MSG="blastall could not be found on the system."
		DEBUG_MSG="blastall was found."
		exit_if_error

		which clustalw2 > /dev/null
		RETVAL=$?
		ERROR_MSG="clustalw (clustalw2) could not be found on the system."
		DEBUG_MSG="clustalw (clustalw2) was found."
		exit_if_error
fi
# Checking parallel programs
if [ "${EXECUTION}" == "Parallel" ]
	then

		which mpiformatdb > /dev/null
		RETVAL=$?
		ERROR_MSG="mpiformatdb could not be found on the system."
		DEBUG_MSG="mpiformatdb was found."
		exit_if_error

		which mpiexec > /dev/null
		RETVAL=$?
		ERROR_MSG="mpiexec could not be found on the system."
		DEBUG_MSG="mpiexec was found."
		exit_if_error

		which mpiblast > /dev/null
		RETVAL=$?
		ERROR_MSG="mpiblast could not be found on the system."
		DEBUG_MSG="mpiblast was found."
		exit_if_error

		which clustalw-mpi > /dev/null
		RETVAL=$?
		ERROR_MSG="clustalw-mpi could not be found on the system."
		DEBUG_MSG="clustalw-mpi was found."
		exit_if_error
fi
# If everything went well, call exit
NORMAL_MSG="All required programs have been found."
exit_success