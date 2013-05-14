#######
# INSTALLATION VARIABLES
#######
# Below are the installation variables that will need to be set.
#######

# Location of mpirun on the system
# Please note this mpirun should be able to run the programs
# required by the pipeline! They should have been compiled to
# be run by this mpirun.
#MPIRUN=${MPIRUN:-$(which mpirun)}

#Defaults, if any -- comment out if no default wanted

# Number of nodes to use when/if running in parallel
NnodesDefault=20

# Default direction of the sequences -- FORWARD or REVERSE
DirectionDefault="FORWARD"

# Percent of Ns accepted in a sequence; above this percent,
# the sequence will be considered bad and not included
NpercentDefault=.03

# Default number of hits to use from the BLAST
NhitsDefault=25

# Default sequence to root the tree around -- can be blank
RootDefault="Methanococcus_jannaschii"

# The 3' primer used to acquire the sequences; will be cut off
Primer3Default="GACTCGGTCC"

# The 5' primer used to acquire the sequences; will be cut off
Primer5Default="CCTAGTGGAGG"

# Default database to use
#DatabaseDefault=/path/to/database

# Default sequence to use to blast against existing sequences to determine direction
BlastSeqDefault="$scriptdir/../references/af243169.for"

# Suffix of the sequences to be analyzed
SuffixDefault=".seq"

# Default list of reference strains in FASTA format
RefStrainsDefault="$scriptdir/../references/RefStrains"

# Default minimum sequence length
MinSeqLengthDefault=500

# Default maximum number of simultaneous BLAST jobs
MaxBlasts=50
