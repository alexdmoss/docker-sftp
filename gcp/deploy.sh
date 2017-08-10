#!/usr/bin/env bash
#
# [ADM, 2017-08-08] deploy.sh [--install]
#
# Deploys latest image to GKE by applying Kubernetes deployment manifest,
# after automatically updating with latest image tag in GCR.
#
# If --install specified, it is first-time execution. Following are performed:
#  1. Kubernetes namespace defined
#  2. Persistent disk allocated in GCP
#  3. Static IP allocated in GCP
#  4. Kubernetes .yml manifests for persistent volumes generated and applied
#  5. Kubernetes .yml manifests for deployment & service generated

# source global variables
. ${SFTP_BUILD_DIR}/config/vars.sh

# check required variables set
if [[ -z ${GCP_PROJECT_NAME} ]];  then echo "[ERROR] GCP_PROJECT_NAME not set, aborting.";  exit 1; fi
if [[ -z ${IMAGE_NAME} ]];        then echo "[ERROR] IMAGE_NAME not set, aborting.";        exit 1; fi
if [[ -z ${VERSION} ]];           then echo "[ERROR] VERSION not set, aborting.";           exit 1; fi
if [[ -z ${NAMESPACE} ]];         then echo "[ERROR] NAMESPACE not set, aborting.";         exit 1; fi
if [[ -z ${STORAGE_CAP} ]];       then echo "[ERROR] STORAGE_CAP not set, aborting.";       exit 1; fi

BUILD_IMAGE=eu.gcr.io/${GCP_PROJECT_NAME}/${IMAGE_NAME}

# installing for first time - run one-time setup activities
if [[ $1 == "--install" ]]; then

  # set up secrets/ dirs
  mkdir -p ${SFTP_BUILD_DIR}/secrets/public-keys/
  mkdir -p ${SFTP_BUILD_DIR}/secrets/ssh/

  # defines kubernetes namespace from template
  cat ${SFTP_BUILD_DIR}/k8s/templates/create-namespace.yml \
  | sed 's#${NAMESPACE}#'${NAMESPACE}'#g' \
  > ${SFTP_BUILD_DIR}/k8s/create-namespace.yml

  kubectl apply -f ${SFTP_BUILD_DIR}/k8s/create-namespace.yml

  # creates some persistent disk to use
  ${SFTP_BUILD_DIR}/gcp/create-persistent-disk.sh
  cat ${SFTP_BUILD_DIR}/k8s/templates/create-persistent-disk.yml \
  | sed 's#${NAMESPACE}#'${NAMESPACE}'#g' \
  | sed 's#${IMAGE_NAME}#'${IMAGE_NAME}'#g' \
  | sed 's#${STORAGE_CAP}#'${STORAGE_CAP}'#g' \
  > ${SFTP_BUILD_DIR}/k8s/create-persistent-disk.yml

  kubectl apply -f ${SFTP_BUILD_DIR}/k8s/create-persistent-disk.yml

  # defines a static IP to bind the pod to - .yml is also updated by this
  STATIC_IP=$(${SFTP_BUILD_DIR}/gcp/create-static-ip.sh)

  # generates yaml with static IP + namespace set from template
  cat ${SFTP_BUILD_DIR}/k8s/templates/deployment+service.yml \
  | sed 's#${STATIC_IP}#'${STATIC_IP}'#g' \
  | sed 's#${NAMESPACE}#'${NAMESPACE}'#g' \
  | sed 's#${IMAGE_NAME}#'${IMAGE_NAME}'#g' \
  | sed 's#${BUILD_IMAGE}#'${BUILD_IMAGE}'#g' \
  > ${SFTP_BUILD_DIR}/k8s/${IMAGE_NAME}.yml

fi

echo "Determining latest image pushed to GCR ..."
LATEST_TAG=$(gcloud container images list-tags ${BUILD_IMAGE} --sort-by="~timestamp" --limit=1 --format='value(tags)')

echo "Updating manifest with image version: ${LATEST_TAG} ..."
cat ${SFTP_BUILD_DIR}/k8s/${IMAGE_NAME}.yml \
| sed 's#${VERSION}#'${LATEST_TAG}'#g' \
> ${SFTP_BUILD_DIR}/k8s/${IMAGE_NAME}-staging.yml

echo "Creating required secrets ..."
${SFTP_BUILD_DIR}/gcp/create-user-secret.sh

echo "Updating Kubernetes deployment ..."
kubectl apply -f ${SFTP_BUILD_DIR}/k8s/${IMAGE_NAME}-staging.yml

echo "Deployment complete. Housekeeping in progress ..."
rm ${SFTP_BUILD_DIR}/k8s/${IMAGE_NAME}-staging.yml

echo "Script complete."

exit 0
