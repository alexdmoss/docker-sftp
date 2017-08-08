Docker SFTP Server
======================

## Description

Lightweight SFTP server running in a docker container.

Extensively hacked from mickaelperrin/docker-sftp-server.

## Features

Lightweight Linux image (Alpine).
Automates user and home directory creation.
Runs in chroot.
Bash script 'launch.sh' can be extended with additional capabilities as required.

## Pre-requisites

gcloud sdk with kubectl
docker (for local build)
GKE cluster defined and authenticated to (for remote install/deploy)

## How to use

1. git clone https://github.com/alexdmoss/docker-sftp
2. [ Edit config/vars.sh to match your desired configuration ]
3. [ Authenticate your GCloud SDK to the desired GCP project ]
4. export SFTP_BUILD_DIR=<path-to-this-dir>
5. ./utils/create-user-key.sh <client-username>
6. ./docker/build.sh
- at this point, you can run the image locally to check it works
7. ./gcp/deploy.sh --install
8. You should now have an accessible SFTP server:
sftp -i <path-to-private-key> <username>@<external-ip>
- by default, the private key has gone into secrets/private-keys/
- the external IP can be obtained from kubectl get svc. It is safe to map DNS to this as long as you do not delete/reallocate the static IP

For subsequent updates to the image, run:
./gcp/deploy.sh
i.e. without the ''--install' flag, which will attempt to redefine static IP, disk, k8s manifests, etc.

./docker/build.sh can be re-run with an updated version in vars.sh as required.

## Detailed Walkthrough

### Variables to set in docker-compose.yml

USERNAME
PASSWORD
OWNER_ID
FOLDER

## Uninstall

There is a script in utils for this purpose:
./utils/destroy.sh
Note that this will remove everything - not just the running pod and its service, but also delete the persistent disk and static IP from GCP too. Data will not be recoverable unless you take a backup!

## To-Do / Future Enhancements

Must-Do's:
- complete docker-compose setup
- Variables in docker-compose/k8s file should be secrets
- Abstract out all the fixed variables in compose/k8s
- example of additional users / launch.d
- UsePrivilegeSeparation deprecation

Future improvements:
- built-in automated testing
- look at global storage and ReadWriteMany to allow parallel deploys
- options with GCP Cloud DNS
- availability checking on rollout
- logging / auditing / monitoring support - e.g. auth.log and stackdriver
- backups
