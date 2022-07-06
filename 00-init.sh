#!/bin/bash

source .env.sh || fatal "Config doesnt exist please create .env.sh"

gcloud config configurations create $GCLOUD_CONFIG |
gcloud config configurations activate $GCLOUD_CONFIG ||
    gcloud config configurations create $GCLOUD_CONFIG
gcloud config set account $ACCOUNT
gcloud config set project $PROJECT_ID
PROJECT_ID=$(gcloud config get-value project)

# Enable APIs...
gcloud services enable \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  clouddeploy.googleapis.com \
  compute.googleapis.com \
  container.googleapis.com \
  sourcerepo.googleapis.com

# Set defaults..
gcloud config set run/region "$REGION"
#gcloud config set build/region "$REGION"
gcloud config set deploy/region "$CLOUD_DEPLOY_REGION"

#gcloud config set run/platform managed
#gcloud config set eventarc/location $REGION

gcloud config list | lolcat

    # If you need to aunthenticate your app
#This is needed when you want to use Python, Node, .. APIs and you cant / dont
#want to use a service account.
#
# gcloud auth application-default login
#
#Once I got a mysterious error which asked me to RE-authorize:
#
# gcloud auth login --update-adc
#

# Needed on a new computer. Smartly installs if needed.
which skaffold >/dev/null && echo skaffold exists. All good. ||
  gcloud components install skaffold

touch ".$APPNAME.appname"

# sets kubetcl context to this cluste TODO ricc paramtyerize region.
gcloud container clusters get-credentials cicd-dev --region europe-west6

# TODO(ricc): check ENV_SH_CONFIG from sourced to the .dist and suggest to check the HISTORY
#             for missing VARs.

# End of your code here
echo Everything is ok.