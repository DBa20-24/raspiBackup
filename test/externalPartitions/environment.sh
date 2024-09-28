#/bin/bash

BACKUP_PART=/dev/sdb1
RESTORE_SD=/dev/sdc
BACKUP_PATH=/backup
BACKUP_DIR=/raspberrypi-bookworm64-lite-extpart
LOG_FILE=test.log

EXTPART1_RESTORE_PATH=$BACKUP_PATH/restore/extMount1
EXTPART1_RESTORE_FILE=$BACKUP_PATH/restore/extMount1/extMount1.txt
EXTPART2_RESTORE_PATH=$BACKUP_PATH/restore/extMount2
EXTPART1_RESTORE_FILE=$BACKUP_PATH/restore/extMount2/extMount2.txt

