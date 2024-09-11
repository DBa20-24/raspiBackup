#!/bin/bash
#

source ./setupMounts4Restore.sh

#sudo ./raspiBackup.sh -M "PlainBackup" --ignoreAdditionalPartitions

#sudo ./raspiBackup.sh -d $RESTORE_SD -Y -T "1" -X "/ext1" $1
#checkPartitionDataExists 1 

sudo ./raspiBackup.sh -d $RESTORE_SD -Y -T "1" -X "/ext1 /ext2" $1
checkPartitionDataExists 1 2






