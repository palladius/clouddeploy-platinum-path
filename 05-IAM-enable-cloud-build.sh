#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal "Config doesnt exist please create .env.sh"
set -x
set -e

function _get_roles_for_service_account() {
  gcloud projects get-iam-policy $PROJECT_ID --filter  bindings.members=serviceAccount:"$1" --flatten="bindings[].members" | grep role: | lolcat
}

#########################################################################################################
# This script provides Cloud Build and Compute Serbive accounts with the necessary privileges to
# run our pipeline.
#########################################################################################################

# Fetch Project Number from Project ID:
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
# Cloud Build SA:
CLOUD_BUILD_SVC_ACCT="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
# GCE SA:
GCE_SVC_ACCT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"


# 1. Add roles to normal Cloud Build SvcAcct
for SUCCINCT_ROLE in \
    artifactregistry.repoAdmin \
    container.developer \
    iam.serviceAccountUser \
    cloudbuild.connectionAdmin \
    clouddeploy.jobRunner \
    clouddeploy.releaser \
    source.reader \
    cloudbuild.builds.builder \
    storage.objectAdmin ; do
  gcloud projects add-iam-policy-binding --member="serviceAccount:${CLOUD_BUILD_SVC_ACCT}" --role "roles/$SUCCINCT_ROLE" "$PROJECT_ID"
done


# 2. Add roles to GCE service account for the GKE nodes (which is usually the default compute account)
for SUCCINCT_ROLE in \
    artifactregistry.reader \
    cloudbuild.connectionAdmin \
    container.developer \
    container.nodeServiceAgent \
    storage.objectCreator \
    ; do
  gcloud projects add-iam-policy-binding --member="serviceAccount:${GCE_SVC_ACCT}" --role "roles/$SUCCINCT_ROLE" "$PROJECT_ID"
done

echo [wow] SuperDuper query on roles for your Cloud Build SvcAcct:
# https://fabianlee.org/2021/01/29/gcp-analyzing-members-of-iam-role-using-gcloud-filtering-and-jq/
white "1. Roles for CLOUD_BUILD_SVC_ACCT $CLOUD_BUILD_SVC_ACCT:"
_get_roles_for_service_account $CLOUD_BUILD_SVC_ACCT

white "2. Roles for GCE_SVC_ACCT $GCE_SVC_ACCT:"
_get_roles_for_service_account $GCE_SVC_ACCT

# End of your code here
_allgood_post_script
echo Everything is ok.
