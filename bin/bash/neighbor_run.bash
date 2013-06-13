#!/bin/bash
#####
# Requires:
#	PERL_DIR
#	NEIGHBOR_DIR
#	NEIGHBOR_ROOT
#	OUTPUT_DIR
#####
# Additional:
#	NEIGHBOR_SCRIPT
#####

# Need to modify makeneighbor.pl to let us specify the name of the output file.


# Make a script for neighbor based on the root we give
EXITCODE=$(${PERL_DIR}/makeneighbor.pl ${NEIGHBOR_DIR} ${NEIGHBOR_ROOT} ${PERL_DIR} ${PERL_DIR}/searchnames.pl)$?
exit ${EXITCODE}



#!/bin/bash
#####
# Requires:
#	NEIGHBOR_DIR
#	NEIGHBOR_SCRIPT
#####

# Generate the final tree given neighbor_script, which was created
# by makeneighbor.pl
cd ${NEIGHBOR_DIR}
echo "Making the tree"
EXITCODE=$(neighbor < ${NEIGHBOR_SCRIPT})$?
exit ${EXITCODE}

#!/bin/bash
#####
# Requires:
#	PERL_DIR

#####

echo "Changing back to full names"
EXITCODE=$(${PERL_DIR}/namesback.pl $OUTPUT_DIR)$?
exit ${EXITCODE}