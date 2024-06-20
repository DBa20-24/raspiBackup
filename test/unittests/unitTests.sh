#!/bin/bash

error=0
#
for utDir in $(find * -type d); do
	echo $utDir
	cd $utDir
	./${utDir}.sh
	e=$?
	if (( e )); then
		echo "$utdir failed"
	fi
	((error=error | e)) 
	cd ..
done

if (( error )); then
	echo "$error UTs failed"
else
	echo "All UTs finished successfully"
fi
