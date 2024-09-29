#/bin/bash

BACKUP_PART=/dev/sdb1		# backup partition
RESTORE_SD=/dev/sdc			# restore device
BACKUP_SD=/dev/mmcblk0		# backup device
BACKUP_PATH=/backup			# backup partition mountpoint
BACKUP_DIR=/raspberrypi-bookworm64-lite-extpart	# backup directory
LOG_FILE=test.log

EXTPART_MP1=/ext1			# external MP1
EXTPART_MP2=/ext2			# external MP2

# external bind directories for backup and restore
EXPTPART_RESTORE_PATH=$BACKUP_PATH/restore
EXPTPART_BACKUP_PATH=$BACKUP_PATH/backup

EXTPART1_RESTORE_PATH=$EXPTPART_RESTORE_PATH/extMount1
EXTPART1_RESTORE_FILE=$EXPTPART_RESTORE_PATH/extMount1/extMount1.txt
EXTPART2_RESTORE_PATH=$EXPTPART_RESTORE_PATH/extMount2
EXTPART2_RESTORE_FILE=$EXPTPART_RESTORE_PATH/extMount2/extMount2.txt
EXTPART1_FILE_CONTENTS="extMount1Contents"
EXTPART2_FILE_CONTENTS="extMount2Contents"

EXTPART1_BACKUP_PATH=$EXPTPART_BACKUP_PATH/extMount1
EXTPART1_BACKUP_FILE=$EXPTPART_BACKUP_PATH/extMount1/extMount1.txt
EXTPART2_BACKUP_PATH=$EXPTPART_BACKUP_PATH/extMount2
EXTPART2_BACKUP_FILE=$EXPTPART_BACKUP_PATH/extMount2/extMount2.txt
