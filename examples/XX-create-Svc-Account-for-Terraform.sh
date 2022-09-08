#!/bin/bash
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


########################################
# This script is just a working test which lays the foundations
# (creates Service Account, download key, uses it to terraform stuff)
# for a TF setup. Since I haven’t come to terraform the rest of this
# project, this is useless from a narrative perspective. But it does
# tear up a sample Cloud Deploy pipeline with targets.
########################################

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
