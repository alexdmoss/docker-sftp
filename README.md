Docker SFTP Server
======================

## Description

Lightweight SFTP server running in a docker container.

Based heavily on mickaelperrin/docker-sftp-server.

### Features

Lightweight Linux image (Alpine).
Automates user and home directory creation.
Runs in chroot.

Bash script 'launch.sh' can be extended with additional capabilities as required.

## How to use

git clone ()
cd sftp-server
docker-compose up

Only run once - create-static-ip.sh will allocate a fixed IP in GKE and generate sftp-server.yml from TPL-sftp-server.yml with that IP

### Variables to set in docker-compose.yml

USERNAME
PASSWORD
OWNER_ID
FOLDER


## TODO

[done] 01. CHROOT not working on GKE - means users can get files outside of /data
[done] 02. Static IP allocation
- updating k8s yaml with IP needs tidy-up
[done] 03. SSH keys for access rather than password.
[done] 04. Do we even need to regen keys on recreate?
05. Build to update tag
06. Automate disk provision
07. Variables in docker-compose/k8s file should be secrets
08. Abstract out all the fixed variables
09. Tidy up and simplify Dockerfile
10. Step-by-step to spin up and maintain for a given usage
11. availability checking
12. monitoring
13. UsePrivilegeSeparation
14. ReadWriteMany to allow parallel deploy?
15. auth.log?
