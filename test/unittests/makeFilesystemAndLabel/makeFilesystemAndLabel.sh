#!/bin/bash

source ../../../raspiBackup.sh

DEVICE_FILE="device.dd"
SFDISK_FILE="mkfs.sfdisk"
LOOP_DEVICE=""

trap "{ sudo losetup -D; rm $DEVICE_FILE;}" SIGINT SIGTERM SIGHUP

function createDeviceWithPartition() {

	LOOP_DEVICE="$(losetup -f)"

	truncate -s 1G $DEVICE_FILE
	sfdisk -f $DEVICE_FILE < $SFDISK_FILE
	losetup -P $LOOP_DEVICE	$DEVICE_FILE

	lsblk -o +fstype
}

error=0

createDeviceWithPartition

makeFilesystemAndLabel /dev/loop0 fat

exit

echo "Testing makePartition"
for p in ${IS_SPECIAL_DEVICE[@]}; do
	echo "Testing $p ..."
	pref="$(makePartition "$p")"
	if [[ "$pref" != "${p}p" ]]; then
		echo "Error $p - got $pref"
		error=1
	fi
	echo "Testing $p 1 ..."
	pref="$(makePartition "$p" 1)"
	if [[ "$pref" != "${p}p1" ]]; then
		echo "Error $p - got $pref"
		error=1
	fi
done

echo
echo "Testing makePartition - no prefix"
for p in ${IS_NOSPECIAL_DEVICE[@]}; do
	echo "Testing $p ..."
	pref="$(makePartition "$p")"
	if [[ "$pref" != "$p" ]]; then
		echo "Error $p - got $pref"
		error=1
	fi
	echo "Testing $p 2 ..."
	pref="$(makePartition "$p" 2)"
	if [[ "$pref" != "${p}2" ]]; then
		echo "Error $p - got $pref"
		error=1
	fi
done

echo
if (( error )); then
	echo "Test failed"
	exit 1
else
	echo  "Test OK"
	exit 0 
fi	
