#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
#set -x
set -e

# Add your code here:
SHOW_VERBOSE_STUFF="false"
SHOW_GCLOUD_ENTITIES="true"
SHOW_PANTHEON_LINKS="true"

echo "+ REGION for DEPLOY:          $CLOUD_DEPLOY_REGION"
echo "+ REGION for EVERYTHING ELSE: $REGION"

if [ "true" = "$SHOW_PANTHEON_LINKS" ]; then 
    echo "== DevConsole useful links START (if you are a UI kind of person) ==" | lolcat
    echo "GKE Workloads: https://console.cloud.google.com/kubernetes/workload/overview?&project=$PROJECT_ID"
    echo "Cloud Build Builds: https://console.cloud.google.com/cloud-build/builds;region=global?&project=$PROJECT_ID"
    echo "Cloud Build Triggers: https://console.cloud.google.com/cloud-build/triggers;region=global?project=$PROJECT_ID"
    echo "Cloud Deploy Pipelines: https://console.cloud.google.com/deploy/delivery-pipelines?project=$PROJECT_ID"
    echo "== DevConsole useful links END =="
fi

kubectl get pods,service

# Docs: https://cloud.google.com/sdk/gcloud/reference/beta/artifacts/docker
if $SHOW_GCLOUD_ENTITIES ; then
    echo "+ Let's count the images for each artifact:"
    gcloud artifacts docker images list "$ARTIFACT_LONG_REPO_PATH" | awk '{print $1}' | sort | uniq -c
    gcloud deploy delivery-pipelines list | egrep "name:|targetId"
fi 
if $SHOW_VERBOSE_STUFF ; then
    gsutil ls -l "gs://$SKAFFOLD_BUCKET/skaffold-cache/"
    gcloud beta builds triggers list --region europe-west6
    skaffold config list
fi

# End of your code here
verde Tutto ok.
