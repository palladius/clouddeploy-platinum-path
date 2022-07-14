#!/bin/bash

function _fatal() {
    echo "$*" >&1
    exit 42
}

# 20 by default
DEFAULT_N_TRIES="20"
N_TRIES=${1:-$DEFAULT_N_TRIES}
# Created with codelabba.rb v.1.5
source .env.sh || _fatal 'Couldnt source this'
#set -x
set -e

########################
# Add your code here
########################
# script dmarziano:

gcloud compute network-endpoint-groups list --filter="$SOL2_SERVICE1"
gcloud compute network-endpoint-groups list --filter="$SOL2_SERVICE2"

IP_FWDRULE=$(gcloud compute forwarding-rules list --filter "$FWD_RULE" | tail -1 | awk '{print $2}')

echo
white "Trying $N_TRIES times to curl my host at IP: $IP_FWDRULE [$FWD_RULE]..."
for i in {0..20}; do
    echo ""; curl -H "Host: xlb-gfe3-host.example.io" $IP_FWDRULE/whereami/pod_name;
done
echo ''






########################
# End of your code here
########################
_allgood_post_script
echo Everything is ok.
