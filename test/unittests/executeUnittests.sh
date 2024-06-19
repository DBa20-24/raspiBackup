#!/bin/bash

error=0

for dir in $(find * -type d); do
#for dir in $(find t -type d); do
	echo $dir
	cd $dir
	./$dir.sh >/dev/null
	e=$?
	echo "$dir $e ...."
	(( error |= $e ))
	cd ..
done

if (( error )); then
	echo "UT: Error"
	exit 1
else
	echo "UT: OK"
	exit 0
fi


