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

	local partitionSizes=($(createResizedSFDisk "$1" "$2" "$testFile"))
	local old=${partitionSizes[0]}
	local new=${partitionSizes[1]}

	local fail=0

	resizedSize="$(calcSumSizeFromSFDISK "$testFile")"

	if (( resizedSize != "$2" )); then
		if [[ -z $3 ]] || ( [[ -n $3 ]] && (( new > 0 )) ); then
			echo -n "FLD --- "
			fail=1
		else
			echo -n "OKN --- "
		fi
	else
		echo -n "OK  --- "
	fi

	echo "Resize $1 to $(bytesToHuman $resizedSize) --- Old partition size: $(bytesToHuman $old) New partitionSize: $(bytesToHuman $new)"

	if (( fail )); then
		echo "Expected: $2 ($(bytesToHuman $2)) - Received: $resizedSize ($(bytesToHuman $resizedSize))"
	fi
}

function test_calcSumSizeFromSFDISK() {

	echo -n "$1: "

	local size="$(calcSumSizeFromSFDISK "$1")"

	if (( size != $2 )); then
		echo -ne "FAILED --- Expected: $2 ($(bytesToHuman $2)) - Received: $size ($(bytesToHuman $size))\n"
	else
		echo -ne "SUCCESS --- $size ($(bytesToHuman $size))\n"
	fi

}

#: <<'SKIP'
echo "--- test_calcSumSizeFromSFDISK ---"
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
#SKIP

exit
echo "--- test_createResizedSFDisk ---"
# shrink
test_createResizedSFDisk "128GB.sfdisk" 31268536320
test_createResizedSFDisk "128GB_nosecsize.sfdisk" 31268536320
test_createResizedSFDisk "28+100GB.sfdisk" 31268536320
test_createResizedSFDisk "28+100GB-1ext.sfdisk" 31268536320
test_createResizedSFDisk "28+5+95GB-2ext.sfdisk" 31268536320
test_createResizedSFDisk "28+95+5GB-2ext.sfdisk" 31268536320
test_createResizedSFDisk "100+28GB.sfdisk" 31268536320 FAIL
# extend
test_createResizedSFDisk "32GB.sfdisk" 128035676160
test_createResizedSFDisk "32GB_nosecsize.sfdisk" 128035676160
test_createResizedSFDisk "10+22GB.sfdisk" 128035676160 $testFile
test_createResizedSFDisk "10+22GB-1ext.sfdisk" 128035676160 $testFile

#rm $testFile
mv $testFile test.sfdisk

