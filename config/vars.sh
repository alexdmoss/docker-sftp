#!/usr/bin/env bash

VERSION=1.7.4
IMAGE_NAME=sftp-server

# GCP
GCP_PROJECT_NAME=moss-work
GCP_REGION=us-east1
GCP_ZONE=us-east1-b
# persistent disk storage in GB to allocate
STORAGE_CAP=1

# Kubernetes
NAMESPACE=mw-sftp
