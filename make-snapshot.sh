#!/bin/bash

lockdir="/tmp/job1_site"
mkdir $lockdir 2>/dev/null || exit $?

dt1=`date "+%F %T"`
res1=$(date +%s.%N)

CURRENT_REGION=$(curl -fs http://metadata.google.internal/computeMetadata/v1/project/attributes/CUREENT_REGION -H "Metadata-Flavor: Google")
MGMT_IP=$(curl -fs http://metadata.google.internal/computeMetadata/v1/project/attributes/MGMT_IP -H "Metadata-Flavor: Google")
ZONE=$(curl -fs http://metadata.google.internal/computeMetadata/v1/project/attributes/CURRENT_ZONE -H "Metadata-Flavor: Google")
HOST_NAME=$(curl -fs http://metadata.google.internal/computeMetadata/v1/instance/hostname -H Metadata-Flavor:Google | cut -d . -f1)

gcloud compute snapshots delete $HOST_NAME -q > /dev/null
gcloud compute disks snapshot $HOST_NAME --snapshot-names $HOST_NAME --zone=$ZONE > /dev/null

var=$((gcloud compute snapshots describe $HOST_NAME | awk 'FNR == 13 {print $2}') | sed 's/\x60/ /g' | sed 's/\x27/ /g')

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
j=$(printf "%02d:%02.2f\n"   $dm $ds)

echo Snapshot,$HOST_NAME,$var,$dt1,$HOST_NAME,:$j  >> /var/log/generallog

rm -rf $lockdir
