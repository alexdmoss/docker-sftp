#!/usr/bin/env bash

# check if defined already
CURR_IP=$(gcloud compute addresses list sftp-server-ip --format=yaml | grep 'address:' | awk '{print $2}')
if [[ $(echo $CURR_IP | wc -w) -eq 0 ]]; then
  gcloud compute addresses create sftp-server-ip --region=us-east1
  ALLOC_IP=$(gcloud compute addresses list sftp-server-ip --format=yaml | grep 'address:' | awk '{print $2}')
  echo "Static IP allocated: $ALLOC_IP"
  cat sftp-server.yml | sed 's/$STATIC_IP/'$ALLOC_IP'/g' > sftp-server-with-ip.yml
else
  echo "Static IP already allocated: $CURR_IP"
fi
