#!/bin/bash
#
./setupMounts4Backup.sh

#sudo ./raspiBackup.sh -M "PlainBackup" --ignoreAdditionalPartitions

#sudo ./raspiBackup.sh -M '\-P -T "*" -X "ext1' -X "/ext1" -P -T "*"

#sudo ./raspiBackup.sh -M '\-P "1" -X "/ext1"' -X "/ext1" -P -T "1"

# sudo ./raspiBackup.sh -M '\-T "1 2" -X "/ext1 /ext2"' -P -T "1 2" -X "/ext1 /ext2" 

sudo ./raspiBackup.sh -M '\-T "1" -X "/ext1 /ext2"' -P -T "1" -X "/ext1 /ext2" 

#sudo ./raspiBackup.sh -M '\-T "5" -X "/ext1 /ext2' -X "/ext1 /ext2" -P -T "5"


