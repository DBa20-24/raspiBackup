#!/bin/bash
#

source ./setupMounts4Restore.sh

#sudo ./raspiBackup.sh -M "PlainBackup" --ignoreAdditionalPartitions

buDir=$(ls -d1 ${BACKUP_PATH}/${BACKUP_DIR}/${BACKUP_DIR}*_1 | tail -1)
sudo ./raspiBackup.sh -d $RESTORE_SD -Y -T "1" -X "/ext1" $buDir
checkPartitionDataExists 1 
checkPartitionExists 1 5 

#sudo ./raspiBackup.sh -d $RESTORE_SD -Y -T "1" -X "/ext1 /ext2" ${BACKUP_PATH}/${BACKUP_DIR}/${BACKUP_DIR}*_2 
#checkPartitionDataExists 1 










