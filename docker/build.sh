#!/usr/bin/env bash
#
# [ADM, 2017-08-08] build.sh
#
# Builds docker image and publishes to Google Container Registry
#
# Notes:
# - As part of CD pipeline, version should be passed in by CI tool, but
#   for this implementation, it is set as global variable.

# source global variables
. ${SFTP_BUILD_DIR}/config/vars.sh

if [[ -z ${GCP_PROJECT_NAME} ]];  then echo "[ERROR] GCP_PROJECT_NAME not set, aborting.";  exit 1; fi
if [[ -z ${IMAGE_NAME} ]];        then echo "[ERROR] IMAGE_NAME not set, aborting.";    exit 1; fi
if [[ -z ${VERSION} ]];           then echo "[ERROR] VERSION not set, aborting.";       exit 1; fi

BUILD_IMAGE=eu.gcr.io/${GCP_PROJECT_NAME}/${IMAGE_NAME}:${VERSION}

# check required files for build exist, create if we can
if [[ ! -f ${SFTP_BUILD_DIR}/config/sshd_config ]]; then
  echo "[ERROR] Missing sshd config file. Aborting."; exit 1
fi
if [[ ! -f ${SFTP_BUILD_DIR}/secrets/ssh/*key ]]; then
  echo "[INFO] No server SSH keys found - creating ..."
  ${SFTP_BUILD_DIR}/docker/create-server-keys.sh
fi

# warn if no public keys present for user (recommended)
if [[ ! "$(ls -A ${SFTP_BUILD_DIR}/secrets/public-keys/)" ]]; then
  echo "[WARN] No public keys found for inclusion in the container image.
               SSH keys are recommended for connecting to the SFTP server"
  echo ""
fi

# build docker image locally
echo; echo "[INFO] Building docker image ${BUILD_IMAGE} ..."
docker build -t ${BUILD_IMAGE} -f ${SFTP_BUILD_DIR}/Dockerfile .

# push to GCR - assumes command line already authenticated
echo; echo "[INFO] Pushing built image to Google Container Registry ..."
gcloud docker -- push ${BUILD_IMAGE}
