#!/usr/bin/env bash
#
# [ADM, 2017-08-07] init.sh
#
# ./init.sh [--reinit] Generates SSH keys for the sshd server to use.
# --reinit: clears existing keys from ssh/ to force generation of new ones.
#
# Moved out of launch.sh as I do not feel it is necessary to regenerate them
# each time the container is recreated, and having to keep known_hosts
# up-to-date is irritating!

set -x

# clear existing keys is argument specified
if [[ $1 = "--reinit" ]]; then rm ssh/*; fi

# Regenerate keys
if [[ ! -f "ssh/ssh_host_rsa_key" ]]; then ssh-keygen -f ssh/ssh_host_rsa_key -N '' -t rsa; fi
if [[ ! -f "ssh/ssh_host_dsa_key" ]]; then ssh-keygen -f ssh/ssh_host_dsa_key -N '' -t dsa; fi
if [[ ! -f "ssh/ssh_host_ecdsa_key" ]]; then ssh-keygen -f ssh/ssh_host_ecdsa_key -N '' -t ecdsa; fi
