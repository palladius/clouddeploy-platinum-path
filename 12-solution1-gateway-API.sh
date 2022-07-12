#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
#set -x
set -e

# Add your code here:

#kubectl config get-contexts | grep cicd | grep "$PROJECT_ID" | grep "$REGION"

# Example west/east
#kubectl apply --context gke-west-1 -f https://raw.githubusercontent.com/GoogleCloudPlatform/gke-networking-recipes/main/gateway/gke-gateway-controller/multi-cluster-gateway/store-west-1-service.yaml
#kubectl apply --context gke-west-2 -f https://raw.githubusercontent.com/GoogleCloudPlatform/gke-networking-recipes/main/gateway/gke-gateway-controller/multi-cluster-gateway/store-west-2-service.yaml

#kubectl apply --context "$GKE_CANARY_CLUSTER_CONTEXT" 
red TODO ricc 
yellow Try a usare la app01 con solution01
white test white removeme

#######################
# End of your code here
#######################
_allgood_post_script
echo Everything is ok.
