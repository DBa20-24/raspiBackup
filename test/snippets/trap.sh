#!/bin/bash

# Borrowed from https://selivan.github.io/2022/05/21/bash-debug.html

function _trap_DEBUG() {
    echo "# $BASH_COMMAND";
    while read -r -e -p "debug> " _command; do
        if [ -n "$_command" ]; then
            eval "$_command";
        else
            break;
        fi;
    done
}

# Borrowed from http://blog.yjl.im/2012/01/printing-out-call-stack-in-bash.html

function logStack () {
	local i=0
	local FRAMES=${#BASH_LINENO[@]}
	# FRAMES-2 skips main, the last one in arrays
	for ((i=FRAMES-2; i>=0; i--)); do
		# echo '  File' \"${BASH_SOURCE[i+1]}\", line ${BASH_LINENO[i]}, in ${FUNCNAME[i+1]}
		# Grab the source code of the line
		sed -n "${BASH_LINENO[i]}{s/^/    /;p}" "${BASH_SOURCE[i+1]}"
	done
}

trap '{ echo "<DEBUG>"; logStack; }' DEBUG
trap '{ echo "<EXIT>"; }' EXIT
trap '{ echo "<ERR>"; }' ERR
	
#trap '_trap_DEBUG' DEBUG

function sub2() {
	trap '{ echo "<RETURN2>"; }' RETURN
	echo ">Sub2 called"
	echo ">Sub2 ended"
}

function sub1() {
	trap '{ echo "<RETURN1>"; }' RETURN
	echo ">Sub1 called"
	( sub2 )
	echo ">Sub1 ended"
}

echo ">Calling sub1"
sub1	

echo ">Call ls"
ls x
