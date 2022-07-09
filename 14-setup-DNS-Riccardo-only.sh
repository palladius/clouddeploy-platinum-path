#!/bin/bash

# These scripts only work for me since i've set up Cloud DNS. I hope they're useful to you as you can
# use them with minimal change.
# TODO(ricc): adapt to $MYDOMAIN

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
#set -x
set -e

# Add your code here:

function riccardo_only_setup_dns() {
    # This is Riccardo only - you can tweak the code to make it work for your zone too.
    #dns-setup-palladius.sh app01-dev.palladi.us 34.65.143.83
    IP="$1"
    HOSTNAME="$2"
    echo "[DEB] Trying to associate $HOSTNAME.apps.palladius.eu to $IP"
    # only works if it doesnt exist already
    gcloud --quiet --project ric-cccwiki beta dns record-sets create --rrdatas="$IP" \
        --type=A --ttl=300 --zone=apps-palladius-eu $HOSTNAME.apps.palladius.eu &&
            echo OK. Created $HOSTNAME.apps.palladius.eu
    #dns-setup-palladius.sh "$HOSTNAME.apps.palladius.eu" "$IP"

}
function getLoadBalancerIP() {
    GKE_CONTEXT="$1"
    SERVICE_NAME="$2"
    #https://stackoverflow.com/questions/47969652/how-do-i-get-the-external-ip-of-a-kubernetes-service-as-a-raw-value
    kubectl --context="$GKE_CONTEXT" get service $SERVICE_NAME --namespace default --output jsonpath='{.status.loadBalancer.ingress[0].ip}'
}
# DEV K8s clusters: Dev, Staging
#riccardo_only_setup_dns 34.65.143.83  app01-dev
#riccardo_only_setup_dns 34.65.143.83  app01-stag
#riccardo_only_setup_dns "$(getLoadBalancerIP $GKE_DEV_CLUSTER_CONTEXT web)" app01-dev
riccardo_only_setup_dns "$(getLoadBalancerIP $GKE_DEV_CLUSTER_CONTEXT app02-kuruby-dev)" app02-dev
#riccardo_only_setup_dns "$(getLoadBalancerIP $GKE_DEV_CLUSTER_CONTEXT web)" app01-staging

# CANARY K8s cluster
#riccardo_only_setup_dns "$(getLoadBalancerIP $GKE_CANARY_CLUSTER_CONTEXT web)" app01-canary # prod
riccardo_only_setup_dns "$(getLoadBalancerIP $GKE_CANARY_CLUSTER_CONTEXT  app02-kuruby)" app02-canary # prod

# PROD K8s cluster
#IP_APP01_PROD=$(getLoadBalancerIP $GKE_PROD_CLUSTER_CONTEXT web)
riccardo_only_setup_dns "$(getLoadBalancerIP $GKE_PROD_CLUSTER_CONTEXT web)" app01 # prod



# End of your code here
_allgood_post_script
echo Everything is ok.