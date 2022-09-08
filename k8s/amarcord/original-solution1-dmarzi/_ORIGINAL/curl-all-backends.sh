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


DEFAULT_IP="34.149.231.48"
IP=${1:-$DEFAULT_IP}


#echo -en 'Autoinferring IP would yield this: '
#gcloud compute forwarding-rules list | grep gkegw | awk '{print $2}' | xargs | lolcat 
echo "1. For your curiosity, these are the current Load Balancers surfaced by GKE Gateway construct:"
gcloud compute forwarding-rules list | grep gkegw | awk '{print $2}' | xargs | lolcat 

function _oneoff_setup_dns() {
#      - "store-bifido.palladius.it"
# This works for Carlesso only:
    RICC_SERVICE_IP="$(gcloud compute forwarding-rules list | grep gkegw  | grep ricc-external-store | awk '{print $2}' )"
    dns-setup-palladius.sh ricc-store.palladius.it "$RICC_SERVICE_IP"
    RICC_SERVICE_IP2="$(gcloud compute forwarding-rules list | grep gkegw  | grep default-bifid-external-store | awk '{print $2}' )"
    dns-setup-palladius.sh store-bifido.palladius.it "$RICC_SERVICE_IP2"
    # gkegw1-jkyr-default-bifid9010-prod-web-gw-q6mrsmmslexp                    34.111.12.6     TCP          gkegw1-jkyr-default-bifid9010-prod-web-gw-q6mrsmmslexp
    dns-setup-palladius.sh bifid9010-foo.palladius.it 34.111.12.6
    #gcloud --quiet --project RICPROJECT beta dns record-sets create --rrdatas='34.117.142.130' --type=A --ttl=300 --zone=palladius-it ricc-store.palladius.it
    #gcloud --quiet --project RICPROJECT beta dns record-sets create --rrdatas='34.117.59.54' --type=A --ttl=300 --zone=palladius-it store-bifido.palladius.it
}
function _curl() {
    curl "$@" 2>/dev/null
}
set -x 

echo "2. curling Ricc Services:"
#RICC_SERVICE_IP="$(gcloud compute forwarding-rules list | grep gkegw  | grep ricc-external-store | awk '{print $2}' )"

#curl -H "host: ricc-store.palladius.it" "http://$RICC_SERVICE_IP/"
#curl http://ricc-store.palladius.it 2>/dev/null
_curl http://ricc-store.palladius.it/storev1 | grep pod_name
_curl http://ricc-store.palladius.it/storev2 | grep pod_name

echo "3. _curling Bifid Services (/v1 /v2 , while / is both):"
_curl http://store-bifido.palladius.it/ | grep pod_name
_curl http://store-bifido.palladius.it/v1/ | grep pod_name
_curl http://store-bifido.palladius.it/v2/whereami/pod_name

# dmarzi curl
curl -H "host: store.example.io" 34.110.177.217/whereami/metadata

echo THE END.

