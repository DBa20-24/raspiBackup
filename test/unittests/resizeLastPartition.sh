#!/bin/bash

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

function createResizedSFDisk() { # sfdisk_source_filename targetSize sfdisk_target_filename

	local sourceFile="$1"
	local targetSize="$2"
	local targetFile="$3"

	local newSize sectorSize

	local partitionregex="/dev/.*[p]?([0-9]+)[^=]+=[^0-9]*([0-9]+)[^=]+=[^0-9]*([0-9]+)[^=]+=[^0-9a-z]*([0-9a-z]+)"

	sectorSize=$(grep "^sector-size:" $sourceFile)
	if (( $? )); then
		sectorSize=512	# not set in buster and earlier, use default
	else
		sectorSize=$(cut -f 2 -d ' ' <<< "$sectorSize")
		if [[ -z $sectorSize ]]; then
			echo "assertion 1 failed"
			exit
		fi
	fi

	local sourceSize=$(calcSumSizeFromSFDISK "$sourceFile")
		
	cp "$sourceFile" "$targetFile"

	if (( sourceSize != targetSize )); then

		local line
		line="$(tail -1 $targetFile)"

		if [[ $line =~ $partitionregex ]]; then
			local p=${BASH_REMATCH[1]}
			local start=${BASH_REMATCH[2]}
			local size=${BASH_REMATCH[3]}
			local id=${BASH_REMATCH[4]}

			if (( $id != 83 )); then
				echo "assertion 1 failed"
				exit
			fi

			if (( sourceSize > targetSize )); then
				(( newSize = ( size - ( sourceSize - targetSize ) / sectorSize ) ))
			else
				(( newSize = ( size + ( targetSize - sourceSize ) / sectorSize ) ))
			fi
			
			sed -i "s/${size}/${newSize}/" $targetFile

		else
			echo "assertion 2 failed"
			exit
		fi
	fi
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

	sectorSize=$(grep "^sector-size:" $file)
	if (( $? )); then
		sectorSize=512	# not set in buster and earlier, use default
	else
		sectorSize=$(cut -f 2 -d ' ' <<< "$sectorSize")
		if [[ -z $sectorSize ]]; then
			echo "assertion 1 failed"
			exit
		fi
	fi

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


test_calcSumSizeFromSFDISK 32GB.sfdisk 31268536320
test_calcSumSizeFromSFDISK 32GB_nosecsize.sfdisk 31268536320
test_calcSumSizeFromSFDISK 128GB.sfdisk 128035676160
test_calcSumSizeFromSFDISK 128GB_nosecsize.sfdisk 128035676160

test_createResizedSFDisk "128GB.sfdisk" 31268536320 "resize.sfdisk"
test_createResizedSFDisk "128GB_nosecsize.sfdisk" 31268536320 "resize.sfdisk"
test_createResizedSFDisk "32GB.sfdisk" 128035676160 "resize.sfdisk"
test_createResizedSFDisk "32GB_nosecsize.sfdisk" 128035676160 "resize.sfdisk"

