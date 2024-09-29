#/bin/bash

source ./setupMounts4.inc

sudo umount $BACKUP_PATH
sudo mount $BACKUP_PART $BACKUP_PATH

unbindAll
sudo mount --bind $EXTPART1_RESTORE_PATH $EXTPART_MP1
sudo mount --bind $EXTPART2_RESTORE_PATH $EXTPART_MP2

sudo rm -rf $EXTPART_MP1/*
sudo rm -rf $EXTPART_MP2/*

#findmnt

