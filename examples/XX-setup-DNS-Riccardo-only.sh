#!/bin/bash
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


######################################################################################################
# These scripts only work for me since i've set up Cloud DNS. I hope they're useful to you as you can
# use them with minimal change.
# Note that to make thisd work you might have to tweak a few things. Please use the followin best
# practice: 
# * Name zone after your domain (since dots are illegal, change them to dashes). Of course this is
#   lossy (my-app.my-domain.com becomes my-app-my-domain-com, and good luck going back!)
######################################################################################################

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
#set -x
set -e

#MY_DOMAIN=apps.mydomain.com
# MY_DASHED_DOMAIN=apps-mydomain-com
export MY_DASHED_DOMAIN="${MY_DOMAIN//./-}"
#set up on your .env.sh export CLOUD_DNS_PROJECT_ID=..."$PROJECT_ID"

_deb "MY_DASHED_DOMAIN: $MY_DASHED_DOMAIN"
# Add your code here:
function _cloud_dns_setup() {
    # This is Riccardo only - you can tweak the code to make it work for your zone too.
    #dns-setup-palladius.sh app01-dev.palladi.us 34.65.143.83
    IP="$1"
    HOSTNAME="$2"
    echo "[DEB] Trying to associate $HOSTNAME.$MY_DOMAIN to $IP"
    # only works if it doesnt exist already
    proceed_if_error_matches "already exists" \
        gcloud --quiet --project "$CLOUD_DNS_PROJECT_ID" beta dns record-sets create --rrdatas="$IP" \
            --type=A --ttl=300 --zone="$MY_DASHED_DOMAIN" $HOSTNAME.$MY_DOMAIN &&
                echo OK. Created $HOSTNAME.$MY_DOMAIN ||
                echo ERR creating $HOSTNAME.$MY_DOMAIN..
    # gcloud --quiet --project ric-cccwiki beta dns record-sets create --rrdatas="$IP" \
    #     --type=A --ttl=300 --zone=apps-palladius-eu $HOSTNAME.$MY_DOMAIN &&
    #         echo OK. Created $HOSTNAME.$MY_DOMAIN
    #dns-setup-palladius.sh "$HOSTNAME.$MY_DOMAIN" "$IP"

}
function getLoadBalancerIP() {
    GKE_CONTEXT="$1"
    SERVICE_NAME="$2"
    NAMESPACE="default"
    #https://stackoverflow.com/questions/47969652/how-do-i-get-the-external-ip-of-a-kubernetes-service-as-a-raw-value
    kubectl --context="$GKE_CONTEXT" get service "$SERVICE_NAME" --namespace "$NAMESPACE" --output jsonpath='{.status.loadBalancer.ingress[0].ip}'
}

# Google Joke: https://twitter.com/honestdns
# So you should be able to test it easily: `ping keep-me-honest.$MYDOMAIN``
_cloud_dns_setup 8.8.8.8 keep-me-honest

# DEV K8s clusters: Dev, Staging
#_cloud_dns_setup 34.65.143.83  app01-dev
#_cloud_dns_setup 34.65.143.83  app01-stag
#_cloud_dns_setup "$(getLoadBalancerIP $GKE_DEV_CLUSTER_CONTEXT web)" app01-dev
#_cloud_dns_setup "$(getLoadBalancerIP $GKE_DEV_CLUSTER_CONTEXT app02-kuruby-dev)" app02-dev
#_cloud_dns_setup "$(getLoadBalancerIP $GKE_DEV_CLUSTER_CONTEXT web)" app01-staging

# CANARY K8s cluster
_cloud_dns_setup "$(getLoadBalancerIP $GKE_CANARY_CLUSTER_CONTEXT app01-kupython)" app01-canary
_cloud_dns_setup "$(getLoadBalancerIP $GKE_CANARY_CLUSTER_CONTEXT app02-kuruby)"   app02-canary 

# PROD K8s cluster
#IP_APP01_PROD=$(getLoadBalancerIP $GKE_PROD_CLUSTER_CONTEXT $$APP01NAME)
_cloud_dns_setup "$(getLoadBalancerIP $GKE_PROD_CLUSTER_CONTEXT app01-kupython)" app01 # prod
_cloud_dns_setup "$(getLoadBalancerIP $GKE_PROD_CLUSTER_CONTEXT app02-kuruby)"   app02 # prod

echo "Lets see if it works:"
for MYHOST in keep-me-honest app01-canary app01-canary app01 app02 ; do
    _deb "Testing host "$MYHOST.$MY_DOMAIN": $(host "$MYHOST.$MY_DOMAIN")" ||
        echo Some errors with "$MYHOST.$MY_DOMAIN"
done

# End of your code here
_allgood_post_script
echo Everything is ok.