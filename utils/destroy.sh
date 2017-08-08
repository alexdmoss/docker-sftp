#!/usr/bin/env bash
#
# [ADM, 2017-08-08] destroy.sh
#
# Blows away the deployed SFTP instance. ALL OF IT!
# Yes, that's right - the persisted disk (i.e. any saved data) will be deleted
# without option to recover (there is no Backup built into this solution),
# and the assigned static IP will be returned
#
# Like, really - you should not run this script unless it is a Test&Dev
# environment.
#
# Steps are as follows:
#   1. Deletes service
#   2. Deletes deployment (pod)
#   3. Deletes persisted disk

. ${SFTP_BUILD_DIR}/config/vars.sh

echo ""
echo " * * * * * * * * * * * * * * W A R N I N G * * * * * * * * * * * * * * "
echo ""
echo " This script will DELETE ALL assets associated with this SFTP server."
echo ""
echo "  - Attached storage will be wiped without recovery"
echo "  - Static IP will be unreserved back to the GCP pool"
echo "  - All Kubernetes assets in the namespace will be removed"
echo ""
echo " Don't say you weren't warned!!"
echo ""
echo " * * * * * * * * * * * * * * W A R N I N G * * * * * * * * * * * * * * "
echo ""
echo " Are you sure you want to continue? (Y/n)"
echo ""
read input


if [[ $input == "Y" ]] || [[ $input == "y" ]]; then

  set -x
  kubectl delete svc ${IMAGE_NAME}-svc --namespace=${NAMESPACE}
  kubectl delete deploy/${IMAGE_NAME} --namespace=${NAMESPACE}
  kubectl delete pvc ${IMAGE_NAME}-pv-claim --namespace=${NAMESPACE}
  kubectl delete pv ${IMAGE_NAME}-pv-volume
  kubectl delete ns ${NAMESPACE}
  gcloud compute disks delete ${NAMESPACE}-pd1
  gcloud compute addresses delete ${NAMESPACE}-ip --region=${GCP_REGION}

else
  echo "[INFO] User aborted."
fi

exit $?
