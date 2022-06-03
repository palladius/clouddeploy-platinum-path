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
  cloudresourcemanager.googleapis.com \
  compute.googleapis.com \
  container.googleapis.com \
  logging.googleapis.com \
  redis.googleapis.com \
  run.googleapis.com \
  servicenetworking.googleapis.com \
  sourcerepo.googleapis.com

# Set defaults..
gcloud config set run/region $REGION
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
which cloud-build-local >/dev/null  && echo cloud-build-local exists. All good. ||
  gcloud components install cloud-build-local
which skaffold >/dev/null && echo skaffold exists. All good. ||
  gcloud components install skaffold

touch ".$APPNAME.appname"
