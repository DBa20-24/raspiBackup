#/bin/bash

source ./setupMounts4.inc

rm $LOG_FILE 2>/dev/null || true
sudo umount $BACKUP_PATH
sudo mount $BACKUP_PART $BACKUP_PATH

unbindAll
sudo mount --bind $EXTPART1_BACKUP_PATH $EXTPART_MP1
sudo mount --bind $EXTPART2_BACKUP_PATH $EXTPART_MP2

sudo rm -rf $EXTPART_MP1/*
sudo rm -rf $EXTPART_MP2/*

echo "$EXTPART1_FILE_CONTENTS" | sudo tee $EXTPART1_BACKUP_FILE > /dev/null
echo "$EXTPART2_FILE_CONTENTS" | sudo tee $EXTPART2_BACKUP_FILE > /dev/null


