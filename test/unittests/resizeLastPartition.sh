#!/bin/bash

#######################################################################################################################
#
# 	 Unit test for sfdisk resize of last partition for raspiBackup
#
#######################################################################################################################
#
#    Copyright (c) 2024 framp at linux-tips-and-tricks dot de
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#######################################################################################################################

source ../../raspiBackup.sh

testFile=$(mktemp)

(( GIB = 1024*1024*1024 ))

GB128=128035676160 # sectors 250069680
GB32=31268536320 # sectors 61071360

function test_createResizedSFDisk() {

	echo -n "$1: "

	local partitionSizes=($(createResizedSFDisk "$1" "$2" "$testFile"))
	local old=${partitionSizes[0]}
	local new=${partitionSizes[1]}

	local fail=0

	resizedSize="$(calcSumSizeFromSFDISK "$testFile")"

	if (( resizedSize != "$2" )); then
		if [[ -z $3 ]] || (( new > 0 )); then
			echo -n "??? --- "
			fail=1
			(( errors ++ ))
		else
			echo -n "OKN --- "
		fi
	else
		echo -n "OK  --- "
	fi

	echo " $resizedSize ($(bytesToHuman $resizedSize)) Old partition size: $(bytesToHuman $old) New partitionSize: $(bytesToHuman $new)"

	if (( fail )); then
		echo "Expected: $2 ($(bytesToHuman $2)) - Received: $resizedSize ($(bytesToHuman $resizedSize))"
	fi
}

function test_calcSumSizeFromSFDISK() {

	echo -n "$1: "

	local size="$(calcSumSizeFromSFDISK "$1")"

	if (( size != $2 )); then
		echo -ne "??? --- Expected: $2 ($(bytesToHuman $2)) - Received: $size ($(bytesToHuman $size))\n"
		(( errors ++ ))
	else
		echo -ne "OK --- $size ($(bytesToHuman $size))\n"
	fi

}

errors=0

 <<'SKIP'
echo "--- test_calcSumSizeFromSFDISK ---"
echo
test_calcSumSizeFromSFDISK "32GB.sfdisk" 31268536320
test_calcSumSizeFromSFDISK "32GB.sfdisk" 31268536320
test_calcSumSizeFromSFDISK "32GB_nosecsize.sfdisk" 31268536320
test_calcSumSizeFromSFDISK "128GB.sfdisk" 128035676160
test_calcSumSizeFromSFDISK "128GB_nosecsize.sfdisk" 128035676160
test_calcSumSizeFromSFDISK "10+22GB.sfdisk" 31268536320
test_calcSumSizeFromSFDISK "10+22GB-1ext.sfdisk" 31268536320
test_calcSumSizeFromSFDISK "10+10+12GB.sfdisk" 31268536320
test_calcSumSizeFromSFDISK "10+10+12GB-1ext.sfdisk" 31268536320
test_calcSumSizeFromSFDISK "100+28GB.sfdisk" 128035676160
test_calcSumSizeFromSFDISK "100+28GB-1ext.sfdisk" 128035676160
test_calcSumSizeFromSFDISK "28+100GB.sfdisk" 128035676160
test_calcSumSizeFromSFDISK "28+100GB-1ext.sfdisk" 128035676160
test_calcSumSizeFromSFDISK "28+5+95GB-2ext.sfdisk" 128035676160
test_calcSumSizeFromSFDISK "28+95+5GB-2ext.sfdisk" 128035676160
test_calcSumSizeFromSFDISK "mmcblk0.sfdisk" 31268536320
test_calcSumSizeFromSFDISK "mmcblk0-2ext.sfdisk" 31268536320
test_calcSumSizeFromSFDISK "nvme0n1.sfdisk" 128035676160
SKIP

echo
echo "--- test_createResizedSFDisk ---"
echo
# shrink
#test_createResizedSFDisk "18-11GB.sfdisk" $((32000000000 - 11999461376 ))
test_createResizedSFDisk "18-11GB.sfdisk" $((32000000000 - ( 11999461376 + 512 ) ))
exit
test_createResizedSFDisk "128GB.sfdisk" 31268536320
test_createResizedSFDisk "128GB_nosecsize.sfdisk" 31268536320
test_createResizedSFDisk "28+100GB.sfdisk" 31268536320
test_createResizedSFDisk "28+100GB-1ext.sfdisk" 31268536320
test_createResizedSFDisk "28+5+95GB-2ext.sfdisk" 31268536320
test_createResizedSFDisk "28+95+5GB-2ext.sfdisk" 31268536320 FAIL
test_createResizedSFDisk "100+28GB.sfdisk" 31268536320 FAIL
test_createResizedSFDisk "18-11GB.sfdisk"
# extend
test_createResizedSFDisk "32GB.sfdisk" 128035676160
test_createResizedSFDisk "32GB_nosecsize.sfdisk" 128035676160
test_createResizedSFDisk "10+22GB.sfdisk" 128035676160 
test_createResizedSFDisk "10+22GB-1ext.sfdisk" 128035676160 

#rm $testFile
mv $testFile test.sfdisk

echo
if (( errors > 0 )); then
	echo "??? Test failed with §errors errors"
	exit 1
else
	echo "!!! Test completed without errors"
	exit 0
fi


