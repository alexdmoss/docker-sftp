#!/usr/bin/env bash
#
# [ADM, 2017-08-08] create-server-keys.sh
#
# Run by build.sh to create server SSH keys if they do not exist.
# Can be re-run individually with --reinit argument if keys need to be
# regenerated.
#
# Notes:
# - Was originally in launch.sh but I do not feel it is necessary to regenerate
#   them each time the container is recreated, but can be reintroduced there
#   if security standards demand it. Note this will invalidate known_hosts
#   every time the container is re-deployed due to strict host checking.

. ${SFTP_BUILD_DIR}/config/vars.sh


# clear existing keys is argument specified
if [[ $1 = "--reinit" ]]; then rm ${SFTP_BUILD_DIR}/secrets/ssh/*; fi

# Regenerate keys
if [[ ! -f "${SFTP_BUILD_DIR}/secrets/ssh/ssh_host_rsa_key" ]]; then
  ssh-keygen -f ${SFTP_BUILD_DIR}/secrets/ssh/ssh_host_rsa_key -N '' -t rsa
fi

if [[ ! -f "${SFTP_BUILD_DIR}/secrets/ssh/ssh_host_dsa_key" ]]; then
  ssh-keygen -f ${SFTP_BUILD_DIR}/secrets/ssh/ssh_host_dsa_key -N '' -t dsa
fi

if [[ ! -f "${SFTP_BUILD_DIR}/secrets/ssh/ssh_host_ecdsa_key" ]]; then
  ssh-keygen -f ${SFTP_BUILD_DIR}/secrets/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
fi
