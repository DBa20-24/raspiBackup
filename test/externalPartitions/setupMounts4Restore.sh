#/bin/bash

source ./setupMounts4.inc

sudo umount /backup
sudo mount $BACKUP_PART /backup

unbindAll
sudo mount --bind /backup/restore/extMount1 /ext1
sudo mount --bind /backup/restore/extMount2 /ext2
sudo rm -rf /ext1/*
sudo rm -rf /ext2/*

#findmnt

