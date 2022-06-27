#!/bin/bash

MODULE_TO_BUILD="${1:-app01}"
COLOR=${2:-orange}

# Created with codelabba.rb v.1.4a
source .env.sh || fatal "Config doesnt exist please create .env.sh"
set -x
set -e

# Install cloud-build-local if we don't have it yet
which cloud-build-local >/dev/null  && echo cloud-build-local exists. All good. ||
  gcloud components install cloud-build-local

# Doesnt seem to pick it up from .env.sh.. BUG FOUND! Now commenting :)
# I was setting up the Cloud Region to Belgium, but then below I had boilerplate to set it to region.. which put it back to Zurich :/
#CLOUD_DEPLOY_REGION="europe-west1"

# Add your code here:
# docs for substitutions: https://cloud.google.com/build/docs/configuring-builds/substitute-variable-values
#  --substitutions "_DEPLOY_UNIT=$MODULE_TO_BUILD,_REGION=$REGION,_ARTIFACT_REPONAME=$ARTIFACT_REPONAME,_DEPLOY_REGION=$CLOUD_DEPLOY_REGION,_APP_VERSION=$PARTICULAR_VERSION_FOR_MODULE" \

PARTICULAR_VERSION_FOR_MODULE=$(cat apps/$MODULE_TO_BUILD/VERSION )

cloud-build-local --config="cloudbuild.yaml" --dryrun=false \
  --substitutions "_DEPLOY_UNIT=$MODULE_TO_BUILD,_REGION=$REGION,_ARTIFACT_REPONAME=$ARTIFACT_REPONAME,_DEPLOY_REGION=$CLOUD_DEPLOY_REGION" \
  --push apps/app01/

# End of your code here
echo Everything is ok.