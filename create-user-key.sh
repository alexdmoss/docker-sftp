#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then 
  echo "Username not specified. Usage: ./create-user-key.sh $USERNAME"
  exit 1
fi

USERNAME=$1

ssh-keygen -f private-keys/${USERNAME}.key -b 4096 -N '' -t rsa
mv private-keys/${USERNAME}.key.pub public-keys/

