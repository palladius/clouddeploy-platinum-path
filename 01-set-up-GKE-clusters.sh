#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
set -x
set -e

# Add your code here:

echo "Here we set up two clusters, cicd-dev/cicd-prod (one for prod and one for everything else). We set up everything in region $REGION" | lolcat


gcloud container --project "$PROJECT_ID" clusters create-auto "cicd-prod" --region "$REGION" \
  --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/default" \
  --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22" # --labels "env=prod"
gcloud container --project "$PROJECT_ID" clusters create-auto "cicd-dev" --region "$REGION" \
  --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/default" \
  --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22"

gcloud auth configure-docker $REGION-docker.pkg.dev





# End of your code here
verde Tutto ok.
