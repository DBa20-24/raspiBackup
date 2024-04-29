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

function test_createResizedSFDisk() {

	createResizedSFDisk $1 $2 $3

	local resizedSize
	resizedSize=$(calcSumSizeFromSFDISK $3)

	if (( resizedSize != $2 )); then
		echo -n "FAILED --- "
	else
		echo -n "SUCCESS ---"
	fi

	echo "$1: $resizedSize ($(bytesToHuman $resizedSize))"

}

function test_calcSumSizeFromSFDISK() {

	local size="$(calcSumSizeFromSFDISK $1)"

	if (( size != $2 )); then
		echo -n "FAILED --- "
	else
		echo -n "SUCCESS ---"
	fi

	echo "$1: $size ($(bytesToHuman $size))"

}

test_calcSumSizeFromSFDISK 32GB.sfdisk 31268536320
test_calcSumSizeFromSFDISK 32GB_nosecsize.sfdisk 31268536320
test_calcSumSizeFromSFDISK 128GB.sfdisk 128035676160
test_calcSumSizeFromSFDISK 128GB_nosecsize.sfdisk 128035676160

test_createResizedSFDisk "128GB.sfdisk" 31268536320 $testFile
test_createResizedSFDisk "128GB_nosecsize.sfdisk" 31268536320 $testFile
test_createResizedSFDisk "32GB.sfdisk" 128035676160 $testFile
test_createResizedSFDisk "32GB_nosecsize.sfdisk" 128035676160 $testFile

rm $testFile

