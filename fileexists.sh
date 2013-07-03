#!/bin/bash
#file=/mnt/home/walt2178/test3/few/output/blast/input/good_sequences
file=/mnt/home/walt2178/test3/bad/output/blast/input/good_sequences
[ ! -s "$file" ] && echo "$file is empty" || echo "$file has content"

if [ ! -s "${file}" ] && [ ! -s "${file}" ] 
then
	echo "${file} is REALLY empty &&"
fi

if [ ! -s "${file}" ] || [ ! -s "${file}" ] 
then
	echo "${file} is REALLY empty ||"
fi