#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
set -x
set -e

# Add your code here:
kubectl config get-contexts

#DEV="gke_${PROJECT_ID}_europe-west6_cicd-dev"
#CAN="gke_${PROJECT_ID}_europe-west6_cicd-canary"
#PRD="gke_${PROJECT_ID}_europe-west6_cicd-prod"

#kubectl apply --context gke-west-1 -f https://raw.githubusercontent.com/GoogleCloudPlatform/gke-networking-recipes/main/gateway/gke-gateway-controller/multi-cluster-gateway/store-west-1-service.yaml
#kubectl apply --context gke-west-2 -f https://raw.githubusercontent.com/GoogleCloudPlatform/gke-networking-recipes/main/gateway/gke-gateway-controller/multi-cluster-gateway/store-west-2-service.yaml
kubectl apply --context "$GKE_CANARY_CLUSTER_CONTEXT" 

#######################
# End of your code here
#######################
_allgood_post_script
echo Everything is ok.
