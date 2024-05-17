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

function test_createResizedSFDisk() {

	local partitionSizes=($(createResizedSFDisk "$1" "$2" "$3" "$4" "$5"))
	local old=${partitionSizes[0]}
	local new=${partitionSizes[1]}

	resizedSize="$(calcSumSizeFromSFDISK "$3")"

#	if (( resizedSize != "$2" || "$4" != "$old" || "$5" != "$new" )); then
	if (( resizedSize != "$2" )); then
		echo -ne "FAILED --- Expected: $2 ($(bytesToHuman $2)) - Received: $resizedSize ($(bytesToHuman $resizedSize))\n"
	else
		echo -n "SUCCESS --- "
	fi

	echo "Resize $1 to $(bytesToHuman $resizedSize) --- Old partition size: $(bytesToHuman $old) New partitionSize: $(bytesToHuman $new)"

}

function test_calcSumSizeFromSFDISK() {

	local size="$(calcSumSizeFromSFDISK "$1")"

	if (( size != $2 )); then
		echo -ne "FAILED --- Expected: $2 ($(bytesToHuman $2)) - Received: $size ($(bytesToHuman $size))\n"
	else
		echo -n "SUCCESS ---"
	fi

	echo "$1: $size ($(bytesToHuman $size))"

}

: <<'SKIP'
echo "--- test_calcSumSizeFromSFDISK ---"
test_calcSumSizeFromSFDISK "32GB.sfdisk" 31268536320
test_calcSumSizeFromSFDISK "32GB.sfdisk" $((32*$GIB))
test_calcSumSizeFromSFDISK "32GB_nosecsize.sfdisk" 31268536320
test_calcSumSizeFromSFDISK "128GB.sfdisk" 128035676160
test_calcSumSizeFromSFDISK "128GB_nosecsize.sfdisk" 128035676160
test_calcSumSizeFromSFDISK "10+22GB.sfdisk" 31268536320
test_calcSumSizeFromSFDISK "10+22GB-1ext.sfdisk" 31268536320
test_calcSumSizeFromSFDISK "100+28GB.sfdisk" 128035676160
test_calcSumSizeFromSFDISK "100+28GB-1ext.sfdisk" 128035676160
test_calcSumSizeFromSFDISK "loop.sfdisk" $((32*$GIB))
SKIP

echo "--- test_createResizedSFDisk ---"
# shrink
test_createResizedSFDisk "128GB.sfdisk" 31268536320 $testFile 126953545728 30186405888
test_createResizedSFDisk "128GB_nosecsize.sfdisk" 31268536320 $testFile 126953545728 30186405888
test_createResizedSFDisk "100+28GB.sfdisk" 31268536320 $testFile 126953545728 30186405888
test_createResizedSFDisk "100+28GB-1ext.sfdisk" 31268536320 $testFile 126953545728 30186405888
# extend
test_createResizedSFDisk "32GB.sfdisk" 128035676160 $testFile 30186405888 126953545728
test_createResizedSFDisk "32GB_nosecsize.sfdisk" 128035676160 $testFile 30186405888 126953545728
test_createResizedSFDisk "10+22GB.sfdisk" 128035676160 $testFile 30186405888 126953545728
test_createResizedSFDisk "10+22GB-1ext.sfdisk" 128035676160 $testFile 30186405888 126953545728
test_createResizedSFDisk "loop.sfdisk" 128035676160 $testFile 30186405888 126953545728

#rm $testFile
mv $testFile test.sfdisk

