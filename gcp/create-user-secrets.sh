#!/usr/bin/env bash
#
# [ADM, 2017-08-09] create-user-secrets.sh
#
# Run by build.sh to create user/pass secrets in k8s.
#
# Relies on files in secrets/users/ - which should not be version-controlled!
#
# Format of files is $USERNAME.txt, where file contains the password for the
# user only.

. ${SFTP_BUILD_DIR}/config/vars.sh

# Loop through secrets/users/, creating k8s secrets from the entries
for f in ${SFTP_BUILD_DIR}/secrets/users/*; do
  USERNAME=$(basename $f)
  PASSWORD=$(cat $f)
  kubectl create secret generic ${IMAGE_NAME}-sec \
    --from-literal=username=${USERNAME} \
    --from-literal=password=${PASSWORD} \
    -o yaml \
    --dry-run \
  | kubectl replace -f -
done
