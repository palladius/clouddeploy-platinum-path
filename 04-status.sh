#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal "Config doesnt exist please create .env.sh"
#set -x
set -e

function show_k8s_stuff() {
#     GKE_DEV_CLUSTER_CONTEXT="gke_cicd-platinum-test001_europe-west6_cicd-dev"
# GKE_CANARY_CLUSTER_CONTEXT="gke_cicd-platinum-test001_europe-west6_cicd-canary"
# GKE_PROD_CLUSTER_CONTEXT="gke_cicd-platinum-test001_europe-west6_cicd-prod"
    # I have 3 clusters and for each I want to show things..
    for CONTEXT in $GKE_DEV_CLUSTER_CONTEXT $GKE_CANARY_CLUSTER_CONTEXT $GKE_PROD_CLUSTER_CONTEXT ; do
        yellow "== ClusterContext: $CONTEXT =="
        # https://stackoverflow.com/questions/33942709/run-a-single-kubectl-command-for-a-specific-project-and-cluster
        # if it doesnt work this should work: kubectl config use-context CONTEXT_NAME
        # RIP echo_do
        echo kubectl --context="$CONTEXT" get service,gatewayclass 2>/dev/null
             kubectl --context="$CONTEXT" get service,gatewayclass 2>/dev/null ||
                echo "Possibly empty output for cluster in $CONTEXT"
    done
}

function show_gcloud_stuff() {
    echo "+ Let's count the images for each artifact:"
    gcloud artifacts docker images list "$ARTIFACT_LONG_REPO_PATH" | awk '{print $1}' | sort | uniq -c
    gcloud deploy delivery-pipelines list | egrep "name:|targetId"
    gcloud compute target-http-proxies list
}

# Add your code here:
SHOW_VERBOSE_STUFF="false"
SHOW_GCLOUD_ENTITIES="true"
SHOW_DEVCONSOLE_LINKS="true"
SHOW_KUBERNETES_STUFF="false"
SHOW_SKAFFOLD_STUFF="false"

echo "+ REGION for DEPLOY:          $CLOUD_DEPLOY_REGION"
echo "+ REGION for GKE:             $GKE_REGION"
echo "+ REGION for EVERYTHING ELSE: $REGION"

#echo TODO kubectl get pods (TODO first add correct context)
#kubectl get pods,service
gcloud beta builds triggers list --region $REGION

if [ "true" = "$SHOW_SKAFFOLD_STUFF" ]; then
    echo "== skaffold info ==" | lolcat
    skaffold config list
fi

if [ "true" = "$SHOW_DEVCONSOLE_LINKS" ]; then
    echo "== DevConsole useful links START (if you are a UI kind of person) ==" | lolcat

    white "[GKE] k8s Workloads: https://console.cloud.google.com/kubernetes/workload/overview?&project=$PROJECT_ID"
    white "[Cloud Build] Global Builds (our triggers): https://console.cloud.google.com/cloud-build/builds;region=global?&project=$PROJECT_ID"
    white "[Cloud Build] Regio Builds (from CDeploy): https://console.cloud.google.com/cloud-build/builds;region=$REGION?&project=$PROJECT_ID"
    white "[Cloud Build] Triggers: https://console.cloud.google.com/cloud-build/triggers;region=global?project=$PROJECT_ID"
    white "[Cloud Deploy] Pipelines: https://console.cloud.google.com/deploy/delivery-pipelines?project=$PROJECT_ID"
    white "Cloud Source Repositories (CSR): https://source.cloud.google.com/$PROJECT_ID"
    white "Network Endpoint Groups (NEGs): https://console.cloud.google.com/compute/networkendpointgroups/list?project=$PROJECT_ID"
    white "Load Balancers (HTTP LBs): https://console.cloud.google.com/net-services/loadbalancing/list/loadBalancers?project=$PROJECT_ID"
    echo "== DevConsole useful links END =="
fi

if [ "true" = $SHOW_KUBERNETES_STUFF ] ; then
    show_k8s_stuff
fi

# Docs: https://cloud.google.com/sdk/gcloud/reference/beta/artifacts/docker
if [ "true" = "$SHOW_GCLOUD_ENTITIES" ] ; then
    show_gcloud_stuff
fi
if [ "true" = "$SHOW_VERBOSE_STUFF" ] ; then
    gsutil ls -l "gs://$SKAFFOLD_BUCKET/skaffold-cache/"
    gcloud beta builds triggers list --region $REGION
    skaffold config list
fi

echo TODO get for both apps/pipelines, for every target the current release similar to https://screenshot.googleplex.com/AuKQWtQsfAvvdsb

# End of your code here
_allgood_post_script
echo Everything is ok.
