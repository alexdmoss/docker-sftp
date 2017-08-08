#!/usr/bin/env bash
#
# [ADM, 2017-08-08] create-user-key.sh
#
# Generates a user ssh key for use by the SFTP server.
# Will be automatically added to the container image if present, but is
# optional (user/pass authentication can be used).

. ${SFTP_BUILD_DIR}/config/vars.sh

if [[ $# -ne 1 ]]; then
  echo "[ERROR] Username not specified. Usage: ./create-user-key.sh <username>"
  exit 1
fi

USERNAME=$1

ssh-keygen -f ${SFTP_BUILD_DIR}/secrets/private-keys/${USERNAME}.key -b 4096 -N '' -t rsa

# we only want to add the public key to the container!
# private key should be moved somewhere secure for the client
mv ${SFTP_BUILD_DIR}/secrets/private-keys/${USERNAME}.key.pub ${SFTP_BUILD_DIR}/secrets/public-keys/
