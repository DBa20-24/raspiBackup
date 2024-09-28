#/bin/bash

source ./setupMounts4.inc

rm $LOG_FILE 2>/dev/null || true
sudo umount /backup
sudo mount $BACKUP_PART /backup

unbindAll
sudo mount --bind /backup/backup/extMount1 /ext1
sudo mount --bind /backup/backup/extMount2 /ext2

#findmnt
	


