#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
#set -x
set -e

DEFAULT_APP="app01"
APP_NAME="${1:-$DEFAULT_APP}"

K8S_IMAGE="skaf-app01-python-buildpacks"
K8S_SELECTOR="app: ??"
# Add your code here:

#kubectl config get-contexts | grep cicd | grep "$PROJECT_ID" | grep "$REGION"

# Example west/east
#kubectl apply --context gke-west-1 -f https://raw.githubusercontent.com/GoogleCloudPlatform/gke-networking-recipes/main/gateway/gke-gateway-controller/multi-cluster-gateway/store-west-1-service.yaml
#kubectl apply --context gke-west-2 -f https://raw.githubusercontent.com/GoogleCloudPlatform/gke-networking-recipes/main/gateway/gke-gateway-controller/multi-cluster-gateway/store-west-2-service.yaml

#kubectl apply --context "$GKE_CANARY_CLUSTER_CONTEXT" 
white "Usage (as I want it): $0 <APPNAME> <..>" 
red TODO ricc implement this for App01/02.
yellow Try to use app01 with solution01 and make it parametric in ARGV..
white "Now I proceed to apply solution 1 for: $APP_NAME. If wrong, call me with proper usage."

#######################
# End of your code here
#######################
_allgood_post_script
echo Everything is ok.
