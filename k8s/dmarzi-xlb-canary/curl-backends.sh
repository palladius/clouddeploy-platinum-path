#!/bin/bash

DEFAULT_IP="34.149.231.48"
IP=${1:-$DEFAULT_IP}


echo -en 'Autoinferring IP would yield this: '
gcloud compute forwarding-rules list | grep gkegw | awk '{print $2}' | xargs | lolcat 

set -x 

# echo "1. curling dmarzi:"
# curl -H "host: store.example.io" "http://${IP}/" 2>/dev/null
# curl -H "host: store.example.io" "http://${IP}/canary/" 2>/dev/null

echo "2. curling Ricc Services:"
RICC_SERVICE_IP="$(gcloud compute forwarding-rules list | grep gkegw  | grep ricc-external-store | awk '{print $2}' )"

# This works for Carlesso only:
dns-setup-palladius.sh ricc-store.palladius.it "$RICC_SERVICE_IP"
# gcloud --quiet --project ric-cccwiki beta dns record-sets create --rrdatas='34.117.142.130' --type=A --ttl=300 --zone=palladius-it ricc-store.palladius.it
curl -H "host: ricc-store.palladius.it" "http://$RICC_SERVICE_IP/"

echo THE END.

