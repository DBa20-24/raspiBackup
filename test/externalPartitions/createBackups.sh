#!/bin/bash
#
#
source ./setupMounts4Backup.sh

# Create backup with all existing partitions (1,2 and 5)
sudo ./raspiBackup.sh -M '1' -X "/ext1" -P -T "*"

source ./setupMounts4Restore.sh

buDir=$(ls -d1 ${BACKUP_PATH}/${BACKUP_DIR}/${BACKUP_DIR}*_1 | tail -1)
sudo ./raspiBackup.sh -d $RESTORE_SD -Y -T "*" -X "/ext1" $buDir
checkPartitionDataExists 1 2 5
checkExtPartitionDataExists 1 

exit
#sudo ./raspiBackup.sh -d $RESTORE_SD -Y -T "1" -X "/ext1 /ext2" ${BACKUP_PATH}/${BACKUP_DIR}/${BACKUP_DIR}*_2 
#checkPartitionDataExists 1 


# Create backup with first partition only
sudo ./raspiBackup.sh -M '2' -X "/ext1" -P -T "1"

# Create backup with OS partitions only
sudo ./raspiBackup.sh -M '3' -P -T "1 2" -X "/ext1 /ext2" 

# Create backup with 5th partition only
sudo ./raspiBackup.sh -M '5' -X "/ext1 /ext2" -P -T "5"












