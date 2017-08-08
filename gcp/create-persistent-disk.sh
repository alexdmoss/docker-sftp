#!/usr/bin/env bash
#
# [ADM, 2017-08-08] create-persistent-disk.sh
#
# Defines a chunk of persistent disk storage in GCP, which we will
# then map to our container in GKE.
# Amount to allocate is defined as a global variable in vars.sh

. ${SFTP_BUILD_DIR}/config/vars.sh

# @TODO: Check if disk exists already and be immutable
CURR_DISK=$(gcloud compute disks list ${NAMESPACE}-pd1 --format=yaml | grep 'address:' | awk '{print $2}')
if [[ $(echo $CURR_DISK | wc -w) -eq 0 ]]; then
  gcloud compute disks create --size ${STORAGE_CAP}GB --zone ${GCP_ZONE} ${NAMESPACE}-pd1
  echo "[SUCC] Persistent disk allocated"
else
  echo "[INFO] Persistent disk already allocated"
fi
