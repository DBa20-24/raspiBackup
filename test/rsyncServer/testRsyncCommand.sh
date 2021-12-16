#!/bin/bash

# Just some code to get familiar with remote ssh command execution and rsync daemon

source ../../raspiBackup.sh --include

### Command execution
#
# See https://stackoverflow.com/questions/11027679/capture-stdout-and-stderr-into-different-variables how to capture stdout and stderr and rc into different variables
#
## - local command execution -
# 1) Test local result (stdout and stderr) returned correctly
# 2) Test local RCs are returned correctly
#
## - remote command execution via ssh -
# 1) Test remote result (stdout and stderr) received correctly locally
# 2) Test remote execution RCs are returned correctly

source ~/.ssh/rsyncServer.creds
#will define
#SSH_HOST=
#SSH_USER= # pi
#SSH_KEY_FILE= # public key of user

#DAEMON_HOST=
#DAEMON_MODULE="Rsync-Test" # uses DAEMON_MODULE_DIR
#DAEMON_MODULE_DIR="/srv/rsync"
#DAEMON_USER=
#DAEMON_PASSWORD=

if (( $UID != 0 )); then
	echo "Call me as root"
	exit -1
fi

function checkrc() {
	logEntry "$1"
	local rc="$1"
	if (( $rc != 0 )); then
		echo "Error $rc"
		echo $stderr
	else
		echo "OK: $rc"
	fi

	logExit $rc
}

function createTestData() { # directory

	if [[ ! -d $1 ]]; then
		mkdir $1
	fi

	rm -f $1/acl.txt
	rm -f $1/noacl.txt

	touch $1/acl.txt
	setfacl -m u:$USER:rwx $1/acl.txt

	touch $1/noacl.txt

	verifyTestData "$1"
}

function verifyTestData() { # directory

	./testRemote.sh "$1"

}

function getRemoteDirectory() { # target directory

	local -n target=$1

	case ${target[$TARGET_TYPE]} in

		$TARGET_TYPE_SSH | $TARGET_TYPE_DAEMON)
			echo "${target[$TARGET_DIR]}"
			;;

		*) echo "Unknown target ${target[$TARGET_TYPE]}"
			exit -1
			;;
	esac
}

function testRsync() {

	local reply

	echo "@@@ testRsync @@@"

	declare t=(localTarget sshTarget rsyncTarget)
	declare t=(sshTarget)

	for (( target=0; target<${#t[@]}; target++ )); do

		tt="${t[$target]}"
		echo
		echo "@@@ ---> Target: $tt"

		echo "@@@ Creating test data in local dir"
		if [[ $tt == "localTarget" ]]; then
			targetDir="${TEST_DIR}_tgt"
			mkdir -p $targetDir
		else
			targetDir="$(getRemoteDirectory "${t[$target]}" $TARGET_DIR)"
		fi
		createTestData $TEST_DIR

		echo "@@@ Copy local data to remote"
		invokeRsync ${t[$target]} stdout stderr "$RSYNC_OPTIONS" $TARGET_DIRECTION_TO "$TEST_DIR/" "$targetDir"
		checkrc $?
		logItem "$reply"

#		echo "@@@ Verify remote data"
#		See https://unix.stackexchange.com/questions/87405/how-can-i-execute-local-script-on-remote-machine-and-include-arguments
#		printf -v args '%q ' "$targetDir"
#		reply="$(invokeCommand ${t[$target]} stdout stderr "bash -s -- $args"  < ./testRemote.sh)"
#		checkrc $?
#		logItem "$stdout"

		# cleanup local dir
		echo "@@@ Clear local data"
		rm ./$TEST_DIR/*

		echo "@@@ Copy remote data to local"
		invokeRsync ${t[$target]} stdout stderr "$RSYNC_OPTIONS" $TARGET_DIRECTION_FROM "$targetDir/" "$TEST_DIR"
		checkrc $?
		logItem "$stdout"

		echo "@@@ Verify local data"
		verifyTestData "$TEST_DIR"

		echo "@@@ Remote data"
		invokeCommand ${t[$target]} stdout stderr "ls -la "$targetDir/*""
		logItem "$stdout"

		echo "@@@ Clear remote data"
		invokeCommand ${t[$target]} stdout stderr "rm "$targetDir/*""
		logItem "$stdout"

		echo "@@@ Remote data cleared"
		invokeCommand ${t[$target]} stdout stderr "ls -la "$targetDir""
		logItem "$stdout"

#		remote error

		echo "@@@ Error"
		invokeRsync ${t[$target]} stdout stderr "$RSYNC_OPTIONS" $TARGET_DIRECTION_TO "${TEST_DIR}Dummy/" "${targetDir}Dummy"
		checkrc $?
		logItem "$stderr"

	done

}

reset
#verifyRemoteSSHAccessOK
#verifyRemoteDaemonAccessOK
testRsync
