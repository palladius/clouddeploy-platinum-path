#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
set -x
set -e

# Add your code here:

function riccardo_only_setup_dns() {
    # This is Riccardo only - you can tweak the code to make it work for your zone too.
    #dns-setup-palladius.sh app01-dev.palladi.us 34.65.143.83
    IP="$1"
    HOSTNAME="$2"
    echo gcloud --quiet --project ric-cccwiki beta dns record-sets create --rrdatas="$IP" \
        --type=A --ttl=300 --zone=palladi-us $HOSTNAME.palladi.us
}
function getLoadBalancerIP() {
    GKE_CONTEXT="$1"
    SERVICE_NAME="$2"
    #https://stackoverflow.com/questions/47969652/how-do-i-get-the-external-ip-of-a-kubernetes-service-as-a-raw-value
    kubectl --context=$GKE_CONTEXT get service $SERVICE_NAME --namespace default --output jsonpath='{.status.loadBalancer.ingress[0].ip}'
}
# DEV K8s clusters: Dev, Staging
riccardo_only_setup_dns 34.65.143.83  app01-dev
riccardo_only_setup_dns 34.65.143.83  app01-stag
# CANARY K8s cluster

# PROD K8s cluster
IP_APP_PROD=$(getLoadBalancerIP $GKE_PROD_CLUSTER_CONTEXT web)
riccardo_only_setup_dns "$IP_APP_PROD" app01 # prod


# End of your code here
echo Tutto ok.


