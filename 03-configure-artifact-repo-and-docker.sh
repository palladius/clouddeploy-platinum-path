#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal "Config doesnt exist please create .env.sh"
set -x
set -e

# Add your code here:
gcloud container clusters get-credentials cicd-dev --region $REGION --project $PROJECT_ID
#gcloud container clusters get-credentials cicd-dev --region europe-west6 --project cicd-platinum-test001

gcloud auth configure-docker $REGION-docker.pkg.dev

# Skaffold auto-config
skaffold config set default-repo "$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REPONAME"


# End of your code here
verde Tutto ok.
