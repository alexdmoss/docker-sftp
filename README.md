# Dockerised SFTP Server

## Description

Lightweight SFTP server running in a docker container.

Extensively hacked from https://hub.docker.com/r/mickaelperrin/docker-sftp-server/.

## Features

- Lightweight Linux image (Alpine) with hardened sshd_server
- Access via mutual TLS or user/pass
- Optional automated build, install and deploy, including keys/users
- Can be extended with additional capabilities as required

If deploying to GCP:
- Kubernetes manifests for managing the container effectively
- Pinned to static IP in GCP (requirement for the piece of work)
- Persistent disk in GCP

### Key Components

There are quite a lot of wrapper scripts to spin up a working image.
However, the key components to be aware of that drive this solution are:

- config/sshd_config - the SFTP server's hardening configuration
- docker/Dockerfile - the dockerfile for building the image
- docker/launch.sh - the entrypoint script that initialises the container correctly
- k8s/templates/ - various Kubernetes manifests to deploy to Kubernetes.
    There are many variables (as ${}) to set in these which is what most of the wrapper scripts are for, but you can of course just copy/edit yourself

In other words, you can get pretty far with:

  docker build -t ${your-image-name} -f docker/Dockerfile .
  gcloud docker -- push ${your-image-name}
  kubectl apply -f k8s/

## Pre-requisites

1. GCloud SDK with kubectl installed
2. Local Docker
3. For remote install/deploy - GKE cluster defined and authenticated to

## How to use

1. Clone this repo:

    git clone https://github.com/alexdmoss/docker-sftp

2. Edit config/vars.sh to match your desired configuration

3. Authenticate your GCloud SDK to the desired GCP project

4. Define your directory as an environment variable for the scripts:

    export SFTP_BUILD_DIR=<path-to-this-dir>

5. Create user SSH key:

    ./utils/create-user-key.sh <client-username>
    Note: ./gcp/create-user-secrets.sh also an option

6. Build the docker image:

    ./docker/build.sh

    - at this point, you can run the image locally to check it works

7. First-time deploy the image to GKE:

    ./gcp/deploy.sh --install

    - this will carry out one-off activities to set up disk / IP / secrets

8. You should now have an accessible SFTP server:

    sftp -i <path-to-private-key> <username>@<external-ip>

    - by default, the private key has gone into secrets/private-keys/
    - the external IP can be obtained from kubectl get svc. It is safe to map DNS to this as long as you do not delete/reallocate the static IP

For subsequent updates to the image, run:

  ./gcp/deploy.sh

i.e. without the ''--install' flag, which will attempt to redefine static IP, disk, k8s manifests, etc.

./docker/build.sh can be re-run with an updated version in vars.sh as required. Normally, this would be fed in through a CI tool (an easy modification).

## Uninstall

There is a script in utils for this purpose:

  ./utils/destroy.sh

Note that this will remove everything - not just the running pod and its service, but also delete the persistent disk and static IP from GCP too. Data will not be recoverable unless you take a backup!

## To-Do / Future Enhancements

Must-Do's:
- complete docker-compose setup
- make the choice of user keys / user+pass optional
- extend to allow additional users/scripts (part-built - /launch.d)

Future improvements:
- built-in automated testing
- look at global storage and ReadWriteMany to allow parallel deploys
- options with GCP Cloud DNS
- availability checking on rollout
- logging / auditing / monitoring support - e.g. auth.log and stackdriver
- backups
