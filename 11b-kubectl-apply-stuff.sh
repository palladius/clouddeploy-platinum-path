#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
set -e

#PROJECT_NUMBER=$(gcloud projects list --filter="$PROJECT_ID" --format="value(PROJECT_NUMBER)")

# Cluster 1
yellow Lets recall that: CLUSTER_1="$CLUSTER_1"
yellow Lets recall that: CLUSTER_2="$CLUSTER_2"
#yellow "Try now for cluster1=$CLUSTER_1 kubectl apply -f  $GKE_SOLUTION0_ILB_SETUP_DIR/cluster1/"

kubectl config get-contexts

_kubectl_on_both_canary_and_prod get gatewayclass

set -x

# Step 6. Apply the GW Config on Cluster 1.
kubectl --context=$GKE_CANARY_CLUSTER_CONTEXT apply -f "$GKE_SOLUTION0_ILB_SETUP_DIR/cluster1/"
kubectl --context=$GKE_PROD_CLUSTER_CONTEXT   apply -f "$GKE_SOLUTION0_ILB_SETUP_DIR/cluster2/"


echo Restoring cluster 1.
gcloud container clusters get-credentials "$CLUSTER_1"  --region "$GCLOUD_REGION" --project "$PROJECT_ID"

# End of your code here
_allgood_post_script
echo Everything is ok.