#!/bin/bash

LOGFILE="$PWD/ut.log"
rm $LOGFILE &>/dev/null
error=0
#
for utDir in $(find * -type d); do
	if [[ "$utDir" == "makePartition" ]]; then
	cd $utDir
	./${utDir}.sh >> $LOGFILE 
	e=$?
	if (( e )); then
		echo "$utDir failed"
	else
		echo "$utDir succeeded"
	fi
	if (( e )); then
		((error+=1))
	fi 
	cd ..
	fi
done

if (( error > 0 )); then
	echo "$error UTs failed"
else
	echo "All UTs finished successfully"
fi
