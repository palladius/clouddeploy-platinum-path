#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
set -x
set -e

function _sniff_roles_for_service_account() {
  gcloud projects get-iam-policy $PROJECT_ID --filter  bindings.members=serviceAccount:"$1" --flatten="bindings[].members" | grep role: | lolcat
}

# Add your code here:
# Thanks willisc: https://github.com/palladius/next21-demo-golden-path/blob/main/demo-startup.sh
# SLOW!!!
PROJECT_NUMBER=$(gcloud projects list --filter="$PROJECT_ID" --format="value(PROJECT_NUMBER)")
# Cloud Build SA:
CLOUD_BUILD_SVC_ACCT="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
# GCE SA:
GCE_SVC_ACCT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"


# 1. Add roles to normal Cloud Build SvcAcct
for SUCCINT_ROLE in \
    artifactregistry.writer \
    container.developer \
    iam.serviceAccountUser \
    clouddeploy.jobRunner \
    clouddeploy.releaser \
    source.reader \
    cloudbuild.builds.builder \
    storage.objectAdmin ; do
  gcloud projects add-iam-policy-binding --member="serviceAccount:${CLOUD_BUILD_SVC_ACCT}" --role "roles/$SUCCINT_ROLE" "$PROJECT_ID"
done


# 2. Add roles to service account for the GKE nodes (which is usually the default compute account)
for SUCCINT_ROLE in \
    artifactregistry.reader \
    container.nodeServiceAgent ; do
  gcloud projects add-iam-policy-binding --member="serviceAccount:${GCE_SVC_ACCT}" --role "roles/$SUCCINT_ROLE" "$PROJECT_ID"
done

echo [wow] SuperDuper query on roles for your Cloud Build SvcAcct:
# https://fabianlee.org/2021/01/29/gcp-analyzing-members-of-iam-role-using-gcloud-filtering-and-jq/
white "1. Roles for CLOUD_BUILD_SVC_ACCT $CLOUD_BUILD_SVC_ACCT:"
_sniff_roles_for_service_account $CLOUD_BUILD_SVC_ACCT

white "2. Roles for GCE_SVC_ACCT $GCE_SVC_ACCT:"
_sniff_roles_for_service_account $GCE_SVC_ACCT

# End of your code here
verde Tutto ok.
