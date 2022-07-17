#!/bin/bash

function _fatal() {
    echo "$*" >&1
    exit 42
}


# 20 by default
DEFAULT_N_TRIES="10"
N_TRIES=$DEFAULT_N_TRIES
#N_TRIES=${1:-$DEFAULT_N_TRIES}
# Created with codelabba.rb v.1.5
source .env.sh || _fatal 'Couldnt source this'
#set -x
set -e

########################
# Add your code here
########################
DEFAULT_APP="app01"                                # app01 / app02
DEFAULT_APP_SELECTOR="app01-kupython"     # app01-kupython / app02-kuruby
DEFAULT_APP_IMAGE="skaf-app01-python-buildpacks"   # skaf-app01-python-buildpacks // ricc-app02-kuruby-skaffold

APP_NAME="${1:-$DEFAULT_APP}"
K8S_APP_SELECTOR="${2:-$DEFAULT_APP_SELECTOR}"               # => app01-kupython  /
K8S_APP_IMAGE="${3:-$DEFAULT_APP_IMAGE}"


# MultiTenant solution (parametric in $1)
SOL2_SERVICE_CANARY="$APP_NAME-$DFLT_SOL2_SERVICE_CANARY"    # => appXX-sol2-svc-canary
SOL2_SERVICE_PROD="$APP_NAME-$DFLT_SOL2_SERVICE_PROD"    # => appXX-sol2-svc-prod

# script dmarziano:

solution2_tear_up_k8s
exit 43

echo 01a Showing CANARY Endpoints: SOL2_SERVICE_CANARY
gcloud compute network-endpoint-groups list --filter="$SOL2_SERVICE_CANARY" | lolcat
echo 01b Showing PROD Endpoints: SOL2_SERVICE_PROD
gcloud compute network-endpoint-groups list --filter="$SOL2_SERVICE_PROD" | lolcat

IP_FWDRULE=$(gcloud compute forwarding-rules list --filter "$FWD_RULE" | tail -1 | awk '{print $2}')

echo
white "Trying $N_TRIES times to curl my host at IP: $IP_FWDRULE [$FWD_RULE]..."
for i in {0..10}; do
    echo ""; curl -H "Host: xlb-gfe3-host.example.io" $IP_FWDRULE/; # /whereami/pod_name;
done
echo ''






########################
# End of your code here
########################
_allgood_post_script
echo Everything is ok.
