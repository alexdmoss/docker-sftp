#!/usr/bin/env bash
#
# [ADM, 2017-08-08] create-static-ip.sh
#
# Allocates a static IP in GCP (if not already allocated).
#
# Only output should be the static IP itself, as it is read by deploy.sh
# on first-time install.

. ${SFTP_BUILD_DIR}/config/vars.sh

# check if defined already
CURR_IP=$(gcloud compute addresses list ${NAMESPACE}-ip --format=yaml | grep 'address:' | awk '{print $2}')
if [[ $(echo $CURR_IP | wc -w) -eq 0 ]]; then
  gcloud compute addresses create ${NAMESPACE}-ip --region=${GCP_REGION}
  ALLOC_IP=$(gcloud compute addresses list ${NAMESPACE}-ip --format=yaml | grep 'address:' | awk '{print $2}')
  echo "${ALLOC_IP}"
else
  echo "${CURR_IP}"
fi
