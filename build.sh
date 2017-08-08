#!/usr/bin/env bash

VERSION=1.7.3
IMAGE_NAME=eu.gcr.io/moss-work/sftp-server:${VERSION}

set -x
docker build -t $IMAGE_NAME .

gcloud docker -- push eu.gcr.io/moss-work/sftp-server:${VERSION}
