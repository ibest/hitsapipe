#!/bin/sh
# Calls pipeline tests

# Test for if no files exist at all
# Expect: FAILURE
#/mnt/home/walt2178/Projects/rna-pipeline-python-qsub-staging/pipeline2.py --work=/mnt/home/walt2178/test3/no --pref=/mnt/home/walt2178/Projects/rna-pipeline-python-qsub-staging/preferences/no.conf --verbose

# Test for if there are only bad files
# Expect: FAILURE
#/mnt/home/walt2178/Projects/rna-pipeline-python-qsub-staging/pipeline2.py --work=/mnt/home/walt2178/test3/bad --pref=/mnt/home/walt2178/Projects/rna-pipeline-python-qsub-staging/preferences/bad.conf --verbose

# Test for if there is only ONE good file
# Expect: SUCCEED
/mnt/home/walt2178/Projects/rna-pipeline-python-qsub-staging/pipeline2.py --work=/mnt/home/walt2178/test3/one --pref=/mnt/home/walt2178/Projects/rna-pipeline-python-qsub-staging/preferences/one.conf --verbose

# Test for if there are only TWO good files
# Expect: SUCCEED
/mnt/home/walt2178/Projects/rna-pipeline-python-qsub-staging/pipeline2.py --work=/mnt/home/walt2178/test3/two --pref=/mnt/home/walt2178/Projects/rna-pipeline-python-qsub-staging/preferences/two.conf --verbose

# Test for if there are a few good files
# Expect: SUCCEED
#/mnt/home/walt2178/Projects/rna-pipeline-python-qsub-staging/pipeline2.py --work=/mnt/home/walt2178/test3/few --pref=/mnt/home/walt2178/Projects/rna-pipeline-python-qsub-staging/preferences/few.conf --verbose

# Test for if there are many good files (simulate an actual run that should have no errors)
# Expect: SUCCEED
#/mnt/home/walt2178/Projects/rna-pipeline-python-qsub-staging/pipeline2.py --work=/mnt/home/walt2178/test3/many --pref=/mnt/home/walt2178/Projects/rna-pipeline-python-qsub-staging/preferences/many.conf --verbose