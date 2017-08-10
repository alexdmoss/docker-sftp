#!/usr/bin/env bash
#
# [ADM, 2017-08-09] create-user-secret.sh
#
# Run by build.sh to create user/pass secrets in k8s.
#
# Relies on username.txt and password.txt in secrets/users/ - which should
# not be version-controlled!

. ${SFTP_BUILD_DIR}/config/vars.sh

USERNAME=$(cat ${SFTP_BUILD_DIR}/secrets/users/username.txt)
PASSWORD=$(cat ${SFTP_BUILD_DIR}/secrets/users/password.txt)

if [[ $(kubectl get secrets | grep -c ${IMAGE_NAME}) -gt 0 ]]; then
  kubectl create secret generic ${IMAGE_NAME}-sec \
    --from-literal=username=${USERNAME} \
    --from-literal=password=${PASSWORD} \
    -o yaml \
    --dry-run \
  | kubectl replace -f -
else
  kubectl create secret generic ${IMAGE_NAME}-sec \
    --from-literal=username=${USERNAME} \
    --from-literal=password=${PASSWORD}
fi
