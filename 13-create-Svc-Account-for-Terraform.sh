#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
set -x
set -e

# Add your code here:
SVC_ACCT_NAME="terraform-cld-deploy-setup"
TERRAFORM_SVC_ACCT="$SVC_ACCT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

# https://cloud.google.com/iam/docs/creating-managing-service-account-keys#iam-service-account-keys-create-gcloud
# I'm a frenius(TM)
proceed_if_error_matches "Service account $SVC_ACCT_NAME already exists within project" \
    gcloud iam service-accounts create "$SVC_ACCT_NAME" --display-name="SvcAcct to set up Cloud Deploy"

# TODO just missing permissions for this person..
#    iam.serviceAccountUser \
for SUCCINCT_ROLE in \
    artifactregistry.writer \
    container.developer \
    clouddeploy.jobRunner \
    clouddeploy.releaser \
    source.reader \
    editor \
    cloudbuild.builds.builder \
    storage.objectAdmin ; do
  gcloud projects add-iam-policy-binding --member="serviceAccount:${TERRAFORM_SVC_ACCT}" --role "roles/$SUCCINCT_ROLE" "$PROJECT_ID"
done

gcloud iam service-accounts keys create private/tf-cd-sa.key \
    --iam-account="$SVC_ACCT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

ls -al private/


# End of your code here
_allgood_post_script
echo Everything is ok.