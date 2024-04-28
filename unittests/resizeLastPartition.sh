#!/bin/bash

TEST1_FILE="32GB.sfdisk"
TEST2_FILE="128GB.sfdisk"

function test_calcSumSizeFromSFDISK() {
	size="$(calcSumSizeFromSFDISK $1)"
	echo -n "$1: $size ($(bytesToHuman $size)) --- "

	if (( size != $2 )); then
		echo "FAILED"
	else
		echo "SUCCESS"
	fi	
}

function bytesToHuman() {
	local b d s S
	local sign=1
	b=${1:-0}; d=''; s=0; S=(Bytes {K,M,G,T,E,P,Y,Z}iB)
	if (( b < 0 )); then
		sign=-1
		(( b=-b ))
	fi
	while ((b > 1024)); do
		d="$(printf ".%02d" $((b % 1024 * 100 / 1024)))"
		b=$((b / 1024))
		let s++
	done
	if (( sign < 0 )); then
		(( b=-b ))
	fi
	echo "$b$d ${S[$s]}"
}

function calcSumSizeFromSFDISK() { # sfdisk file name

	local file="$1"

# /dev/mmcblk0p1 : start=     8192, size=    83968, Id= c
# or
# /dev/sdb1 : start=          63, size=  1953520002, type=83

	local partitionregex="/dev/.*[p]?([0-9]+)[^=]+=[^0-9]*([0-9]+)[^=]+=[^0-9]*([0-9]+)[^=]+=[^0-9a-z]*([0-9a-z]+)"
	local sumSize=0
	local sectorSize
	
	sectorSize=$(grep "^sector-size:" $file | cut -f 2 -d ' ')
	(( ! $? )) && sectorSize=512	# not set in buster and earlier, use default 

	local line
	line="$(tail -1 $file)"
	if [[ $line =~ $partitionregex ]]; then
		local p=${BASH_REMATCH[1]}
		local start=${BASH_REMATCH[2]}
		local size=${BASH_REMATCH[3]}
		local id=${BASH_REMATCH[4]}

		if (( $id != 83 )); then
			echo "assertion 1 failed"
			exit
		fi

		(( sumSize = ( start + size) * sectorSize ))
		echo "$sumSize"
	else
		echo "assertion 2 failed"
		exit
	fi
}

test_calcSumSizeFromSFDISK $TEST1_FILE 31268536320
test_calcSumSizeFromSFDISK $TEST2_FILE 128035676160
