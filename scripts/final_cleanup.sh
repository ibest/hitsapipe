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

if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###"
	echo -e "\tLOG_DIR: ${LOG_DIR}"
	echo -e "\tFINAL_LOG: ${FINAL_LOG}"
	echo -e "### DEBUG OUTPUT END ###"
fi

# Simply concatenates all log files and places it into the output folder

for i in $(ls --sort=time -r `find ${PBS_O_WORKDIR} -name "*.log"`)
do
	BASE=$(basename $i)
	echo "From $BASE:" >> $FINAL_LOG
	#echo "" >> $FINAL_LOG
	cat $i >> $FINAL_LOG
	echo "" >> $FINAL_LOG
done

if [ ${DEBUG} == "True" ]
then
	echo -e "### DEBUG OUTPUT START ###" >> $FINAL_LOG
	echo -e "\tLOG_DIR: ${LOG_DIR}" >> $FINAL_LOG
	echo -e "\tFINAL_LOG: ${FINAL_LOG}" >> $FINAL_LOG
	echo -e "### DEBUG OUTPUT END ###" >> $FINAL_LOG
fi

echo -n "Everything finished at: " >> $FINAL_LOG
date >> $FINAL_LOG
echo "" >> $FINAL_LOG