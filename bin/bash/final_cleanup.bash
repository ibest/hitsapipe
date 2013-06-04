#!/bin/bash
# Simply concatenates all log files and places it into the output folder

for i in $(ls --sort=time -r `find ${PBS_O_WORKDIR} -name "*.log"`)
do
	BASE=$(basename $i)
	echo "From $BASE:" >> $FINAL_LOG
	echo "" >> $FINAL_LOG
	cat $i >> $FINAL_LOG
	echo "" >> $FINAL_LOG
done

echo -n "Everything finished at: " >> $FINAL_LOG
date >> $FINAL_LOG
echo "" >> $FINAL_LOG