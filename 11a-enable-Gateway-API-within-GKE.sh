#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
set -e

PROJECT_NUMBER=$(gcloud projects list --filter="$PROJECT_ID" --format="value(PROJECT_NUMBER)")

# Daniel says: WORKS ONLY WITH MULTIPLE CLUSTERS IN THE SAME REGION
# Enable (multi-cluster Gateways)[https://cloud.google.com/kubernetes-engine/docs/how-to/enabling-multi-cluster-gateways]
# Blue-Green https://cloud.google.com/kubernetes-engine/docs/how-to/deploying-multi-cluster-gateways#blue-green


# CREATING IN region XXX
# Changed dmarzi-proxy to "platinum-proxy-$GCLOUD_REGION" in case you want to change region after starting this :)
proceed_if_error_matches "already exists" \
     gcloud compute networks subnets create "dmarzi-proxy" \
     --purpose=REGIONAL_MANAGED_PROXY \
     --role=ACTIVE \
     --region="$GCLOUD_REGION" \
     --network='default' \
     --range='192.168.0.0/24' # changed after dmarzi-proxy rename..

# bingo! https://screenshot.googleplex.com/h5ZXAUgy5wWrvqh


# 1. # enable required APIs (project level)
#TODO(ricc): refactor to 00
gcloud services enable \
    container.googleapis.com \
    gkehub.googleapis.com \
    multiclusterservicediscovery.googleapis.com \
    multiclusteringress.googleapis.com \
    trafficdirector.googleapis.com \
    --project=$PROJECT_ID

#2. register clusters to the fleet (cluster level)
gcloud container fleet memberships register "$CLUSTER_1" \
     --gke-cluster "$GCLOUD_REGION/$CLUSTER_1" \
     --enable-workload-identity \
     --project=$PROJECT_ID --quiet

gcloud container fleet memberships register $CLUSTER_2 \
     --gke-cluster $GCLOUD_REGION/$CLUSTER_2 \
     --enable-workload-identity \
     --project=$PROJECT_ID --quiet

# Cluster 1
_deb "Cluster mapping: CANARY CLUSTER_1=$CLUSTER_1"
_deb "Cluster mapping: PROD   CLUSTER_2=$CLUSTER_2"

#yellow "Try now for cluster1=$CLUSTER_1 kubectl apply -f  $GKE_SOLUTION0_ILB_SETUP_DIR/cluster1/"

#3. enable multi-cluster services
gcloud container fleet multi-cluster-services enable \
    --project $PROJECT_ID

#3.5 from https://cloud.google.com/kubernetes-engine/docs/how-to/multi-cluster-services
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
     --member "serviceAccount:$PROJECT_ID.svc.id.goog[gke-mcs/gke-mcs-importer]" \
     --role "roles/compute.networkViewer" \
     --project=$PROJECT_ID

#4.  enable gateway apis
kubectl --context="$GKE_CANARY_CLUSTER_CONTEXT" apply -k "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.4.3"
kubectl --context="$GKE_PROD_CLUSTER_CONTEXT"   apply -k "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.4.3"

#4a. TEST. I should see FOUR not TWO:
_deb "TEST: This command should show you TWO entries for TWO clusters: total 4 lines."
_kubectl_on_both_canary_and_prod get gatewayclass
# TODO assert(wc -l == 4)


#5. enable GKE gateway controller just in GKE01.
gcloud container fleet ingress enable \
    --config-membership="/projects/$PROJECT_ID/locations/global/memberships/$CLUSTER_1" \
     --project="$PROJECT_ID"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
     --member "serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-multiclusteringress.iam.gserviceaccount.com" \
     --role "roles/container.admin" \
     --project="$PROJECT_ID"
     
green "one-off Configuration is Done. Now proceed to 11b to execute upon kubectl on two clusters: ./11b-kubectl-apply-stuff.sh"

# End of your code here
_allgood_post_script
echo Everything is ok.