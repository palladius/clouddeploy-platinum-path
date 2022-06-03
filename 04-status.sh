#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
set -x
set -e

# Add your code here:
VERBOSE="false"

echo REGION: $REGION

# Docs: https://cloud.google.com/sdk/gcloud/reference/beta/artifacts/docker
echodo gcloud artifacts docker images list "$ARTIFACT_LONG_REPO_PATH" 

$VERBOSE && gsutil ls -l "gs://$SKAFFOLD_BUCKET/skaffold-cache/"
kubectl get pods,service
$VERBOSE && gcloud beta builds triggers list --region europe-west6
$VERBOSE && skaffold config list


# End of your code here
verde Tutto ok.
