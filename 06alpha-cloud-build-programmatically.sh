#!/bin/bash

#MODULE_TO_BUILD="${1:-app01}"
#COLOR=${2:-orange}

# Created with codelabba.rb v.1.4a
source .env.sh || fatal "Config doesnt exist please create .env.sh"
set -x
set -e

# Execute code here.
yellow '!WARNING! This is currently in alpha and requries project id whitelisting'
# Following instructions at https://docs.google.com/document/d/1TxMJOAzyth-MMx7boimLY7iEnaDKOu3ZX2QoTzuxUNU/preview#

#1 create service account by calling API in wrong way (!)
gcloud alpha builds connections create github xyz \
      --authorizer-token-secret-version=invalid-token \
      --app-installation-id=-1 \
      --region=us-central1 ||
        echo No probs. This will fail but needs calling to create a SvcAccount.


# 2. giving permissions.
PN=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
P4SA="service-${PN}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${P4SA}" \
    --role="roles/secretmanager.admin"

# 3. Creating connection in certain regiomn. Note not many regions are good so we will use this:
# This integration can be used in the following regions: us-central1, us-west1, us-east1, europe-north1,
#   europe-west1, europe-west4, asia-east1, asia-southeast1,  southamerica-west1.
echo Please follow browser and enable OAuth token to be pulled from Github. This requires opening the link in output on
echo browser and following instructions on browser.

proceed_if_error_matches "ALREADY_EXISTS" \
    gcloud alpha builds connections create github riccardo-repo-conn --region=us-central1

gcloud alpha builds connections describe riccardo-repo-conn --region=us-central1 | grep "stage: COMPLETE"

proceed_if_error_matches "ALREADY_EXISTS" \
    gcloud alpha builds repositories create palladius-repo \
        --remote-uri=https://github.com/palladius/clouddeploy-platinum-path.git \
        --connection=riccardo-repo-conn --region=us-central1

gcloud alpha builds triggers create repository \
--name="riccardo-repo-conn-trigger" \
--repository=projects/${PROJECT_ID}/locations/us-central1/connections/riccardo-repo-conn/repositories/palladius-repo \
      --branch-pattern='main' --build-config="cloudbuild.yaml" \
      --region=us-central1

echo 'TODO(ricc): once and if youre satisfied with this workload you need to update names to be compatible with the ones in script 07'

# End of your code here
_allgood_post_script
echo Everything is ok.
