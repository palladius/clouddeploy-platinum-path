#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal "Config doesnt exist please create .env.sh"
set -x
set -e

# Add your code here:

echo "Here we set up two clusters, cicd-dev/cicd-prod (one for prod and one for everything else). We set up everything in region $REGION" | lolcat
gcloud auth configure-docker $REGION-docker.pkg.dev

echo 'If the error is generic::already_exists then youre good :)'

# CANARY (Similar to prod but smaller)
gcloud container --project "$PROJECT_ID" clusters create-auto "cicd-canary" --region "$REGION" \
  --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/default" \
  --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22" # --labels "env=prod"
# PROD
gcloud container --project "$PROJECT_ID" clusters create-auto "cicd-prod" --region "$REGION" \
  --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/default" \
  --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22" # --labels "env=prod"
# DEV
gcloud container --project "$PROJECT_ID" clusters create-auto "cicd-dev" --region "$REGION" \
  --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/default" \
  --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22"

# Create Artifact Registry
gcloud --project "$PROJECT_ID" artifacts repositories create $ARTIFACT_REPONAME \
    --location="$REGION" --repository-format=docker

# End of your code here. verde script can be found in "palladius/sakura"
verde Everything is ok.
