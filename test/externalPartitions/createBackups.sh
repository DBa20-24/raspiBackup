#!/bin/bash

set -euo pipefail

trap 'err' ERR
trap 'exited' SIGINT SIGTERM EXIT

buDir=""
sourceUUID=""

function exited() {
	sudo umount /mnt 2>/dev/null
}	

function err() {
   echo "??? Unexpected error occured"
   local i=0
   local FRAMES=${#BASH_LINENO[@]}
   for ((i=FRAMES-2; i>=0; i--)); do
      echo '  File' \"${BASH_SOURCE[i+1]}\", line ${BASH_LINENO[i]}, in ${FUNCNAME[i+1]}
      sed -n "${BASH_LINENO[i]}{s/^/    /;p}" "${BASH_SOURCE[i+1]}"
   done
}

function header() {
	echo "########################################################################################"
	echo "$1"
	echo "########################################################################################"
}	

function info() {
	echo "---> $1"
}

source ./setupMounts4Backup.sh
TC="125_12"

:<<SKIP
header "Create backup of partition 1 2 and 5 and ext partition 1 and 2"
sudo ./raspiBackup.sh -M "$TC" -X "/ext1 /ext2" -P -T "1 2 5" >> $LOG_FILE 
SKIP

:<<SKIP
header "restore all partitions and external paritions with repartitioning"
source ./setupMounts4Restore.sh
sourceUUID=$(getUUID)
buDir=$(ls -d1 ${BACKUP_PATH}/${BACKUP_DIR}/${BACKUP_DIR}*_$TC | tail -1)
# restore backup and repartition
sudo ./raspiBackup.sh -d $RESTORE_SD -Y -X "/ext1 /ext2" -T "1 2 5" $buDir >> $LOG_FILE 
set -e
checkPartitionDataExists 1 2 5 
checkExtPartitionDataExists 1 2 
if compareUUID $sourceUUID; then
	echo "??? Repartitioning didn't happen"
	exit
else	
	echo "--- Repartitioning happend"
fi	
set +e
SKIP

:<<SKIP
header "restore partition 1 with repartitioning"
source ./setupMounts4Restore.sh
sourceUUID=$(getUUID)
buDir=$(ls -d1 ${BACKUP_PATH}/${BACKUP_DIR}/${BACKUP_DIR}*_$TC | tail -1)
# restore backup and repartition
sudo ./raspiBackup.sh -d $RESTORE_SD -Y -T "1" $buDir >> $LOG_FILE 
set -e
if ! checkPartitionDataExists 1; then
	echo "??? Partition 1 missing"
	exit
fi	
if checkExtPartitionDataExists 1; then 
	echo "??? ExtPartition 1 exists"
	exit
fi	

if compareUUID $sourceUUID; then
	echo "??? Repartitioning didn't happen"
	exit
fi	
set +e
SKIP

:<<SKIP
header "restore first partition without repartitioning"
source ./setupMounts4Restore.sh
sourceUUID=$(getUUID)
buDir=$(ls -d1 ${BACKUP_PATH}/${BACKUP_DIR}/${BACKUP_DIR}*_$TC | tail -1)
# remove one file and add a new file 
sudo mount ${RESTORE_SD}1 /mnt
sudo rm /mnt/cmdline.txt
sudo touch /mnt/dummy.txt
echo "Dummy" | sudo tee /mnt/issue.txt > /dev/null
sudo umount /mnt 
# restore backup and repartition
sudo ./raspiBackup.sh -d $RESTORE_SD -Y -T "1" -0 $buDir >> $LOG_FILE 
set -e
checkPartitionDataExists 1  
if compareUUID $sourceUUID; then
	echo "??? No repartitioning happend"
	exit
fi	
set +e
sudo mount ${RESTORE_SD}1 /mnt
set -e
echo "Testing for cmdline.txt exists"
if [[ ! -e /mnt/cmdline.txt ]]; then
	echo "cmdline.txt not restored"
	exit
fi	

echo "Testing for dummy.txt deleted"
if [[ -e /mnt/dummy.txt ]]; then
	echo "dummy.txt not deleted"
	exit
fi	

echo "Testing for issue.txt restored"
if grep "Dummy" /mnt/issue.txt; then
	echo "issue.txt not restored"
	exit
fi	
set +e
SKIP

header "restore external partitions only"
source ./setupMounts4Restore.sh
sourceUUID=$(getUUID)
buDir=$(ls -d1 ${BACKUP_PATH}/${BACKUP_DIR}/${BACKUP_DIR}*_$TC | tail -1)
info "restore backup and repartition and keep UUIDs"
sudo ./raspiBackup.sh -d $RESTORE_SD -Y -X "/ext1 /ext2" --updateUUIDs- -T "1" $buDir >> $LOG_FILE
info "remove one file and add a new file and modify one file"
sudo rm $EXTPART1_RESTORE_FILE
sudo touch $EXTPART1_RESTORE_PATH/dummy.txt
echo "Dummy" | sudo tee $EXTPART2_RESTORE_FILE > /dev/null

info "now restore external partitions only"
sudo ./raspiBackup.sh -d $RESTORE_SD -Y -T " " -X "/ext1 /ext2" $buDir >> $LOG_FILE 
set -e
checkExtPartitionDataExists 1 2 
if ! compareUUID $sourceUUID; then
	echo "??? Repartitioning happend"
	exit
fi	
echo "Testing for $EXTPART1_RESTORE_FILE exists"
if [[ ! -e $EXTPART1_RESTORE_FILE ]]; then
	echo "$EXTPART1_RESTORE_FILE not restored"
	exit
fi	

echo "Testing for dummy.txt deleted"
if [[ -e $EXTPART1_RESTORE_PATH/dummy.txt ]]; then
	echo "$EXTPART1_RESTORE_PATH/dummy.txt not deleted"
	exit
fi	

echo "Testing for $EXTPART2_RESTORE_FILE restored"
if ! grep -q "$EXTPART2_FILE_CONTENTS" $EXTPART2_RESTORE_FILE; then
	echo "$EXTPART2_RESTORE_FILE not restored"
	exit
fi	

echo ":-) Test finished"





exit
# Create backup with OS partitions only
sudo ./raspiBackup.sh -M '3' -P -T "1 2" -X "/ext1 /ext2" 

# Create backup with 5th partition only
sudo ./raspiBackup.sh -M '5' -X "/ext1 /ext2" -P -T "5"












