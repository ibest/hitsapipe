#!/bin/bash
#####
# Requires:
#	SOURCE: 		Location to copy from
#	DEST: 			Location to copy to
#####
$(rm -rf ${DEST})
$(mkdir ${DEST})
$(cp -r ${SOURCE}/ ${DEST})