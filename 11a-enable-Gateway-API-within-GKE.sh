#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
set -x
set -e

PROJECT_NUMBER=$(gcloud projects list --filter="$PROJECT_ID" --format="value(PROJECT_NUMBER)")

# Daniel says: WORKS ONLY WITH MULTIPLE CLUSTERS IN THE SAME REGION
# Enable (multi-cluster Gateways)[https://cloud.google.com/kubernetes-engine/docs/how-to/enabling-multi-cluster-gateways]
# Blue-Green https://cloud.google.com/kubernetes-engine/docs/how-to/deploying-multi-cluster-gateways#blue-green


# CREO IN europe-west6
proceed_if_error_matches "already exists" \
     gcloud compute networks subnets create dmarzi-proxy \
     --purpose=REGIONAL_MANAGED_PROXY \
     --role=ACTIVE \
     --region="$GCLOUD_REGION" \
     --network='default' \
     --range='192.168.0.0/24'

# bingo! https://screenshot.googleplex.com/h5ZXAUgy5wWrvqh


# 1. # enable required APIs (project level)
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
     --project=$PROJECT_ID

gcloud container fleet memberships register $CLUSTER_2 \
     --gke-cluster $GCLOUD_REGION/$CLUSTER_2 \
     --enable-workload-identity \
     --project=$PROJECT_ID
# Cluster 1
echo lets recall that: CLUSTER_1="$CLUSTER_1"
echo lets recall that: CLUSTER_2="$CLUSTER_2"
#yellow "Try now for cluster1=$CLUSTER_1 kubectl apply -f  $GKE_SOLUTION1_SETUP_DIR/cluster1/"

gcloud container clusters get-credentials "$CLUSTER_1" --region "$GCLOUD_REGION" --project "$PROJECT_ID"
kubectl config get-contexts
kubectl apply -f  $GKE_SOLUTION1_SETUP_DIR/cluster1/

gcloud container clusters get-credentials "$CLUSTER_2" --region "$GCLOUD_REGION" --project "$PROJECT_ID"
kubectl config get-contexts
kubectl apply -f  $GKE_SOLUTION1_SETUP_DIR/cluster2/

#3. enable multi-cluster services
gcloud container fleet multi-cluster-services enable \
    --project $PROJECT_ID

#3.5 from https://cloud.google.com/kubernetes-engine/docs/how-to/multi-cluster-services
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
     --member "serviceAccount:$PROJECT_ID.svc.id.goog[gke-mcs/gke-mcs-importer]" \
     --role "roles/compute.networkViewer" \
     --project=$PROJECT_ID

#4.  enable gateway apis
kubectl apply -k "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.4.3"
# I should see FOUR not TWO:
kubectl get gatewayclass

#5. enable GKE gateway controller just in GKE01.
gcloud container fleet ingress enable \
    --config-membership=/projects/$PROJECT_ID/locations/global/memberships/$CLUSTER_1 \
     --project=$PROJECT_ID

gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member "serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-multiclusteringress.iam.gserviceaccount.com" \
     --role "roles/container.admin" \
     --project=$PROJECT_ID
     
echo Done. Now proceed to 11b to execute upon kubectl on two clusters: ./11b-kubectl-apply-stuff.sh


# End of your code here
_allgood_post_script
echo Everything is ok.