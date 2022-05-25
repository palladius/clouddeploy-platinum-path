#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
set -x
set -e

# Add your code here:
CLOUD_DEPLOY_REGION="europe-west1"

CLOUD_DEPLOY_TEMPLATING_VER="1-1b"
cat clouddeploy.yaml.template |
  sed -e "s/MY_PROJECT_ID/$PROJECT_ID/g" |
  sed -e "s/MY_REGION/$REGION/g" |
  sed -e "s/_MY_VERSION_/$CLOUD_DEPLOY_TEMPLATING_VER/g" |
  tee clouddeploy.yaml |
  egrep 'cluster|VER' |
  sverda

#yellow TODO
# Zurich doesnt work, :( euw6
gcloud --project $PROJECT_ID deploy apply --file clouddeploy.yaml --region $CLOUD_DEPLOY_REGION







# End of your code here
verde Tutto ok.
