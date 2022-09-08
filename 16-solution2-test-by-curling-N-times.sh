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


DEFAULT_N_TRIES="20"
N_TRIES="$DEFAULT_N_TRIES"
#N_TRIES=${1:-$DEFAULT_N_TRIES}

# Created with codelabba.rb v.1.5
source .env.sh || _fatal 'Couldnt source this'
#set -x
set -e

_cleanup_appxx() {
    APP_NAME="$1"
    echo "$0: todo cleanup $APP_NAME".
    solution2_kubectl_teardown
#    _gcloud_delete_negs_matching_ "$APP_NAME-sol2"
# gcloud compute network-endpoint-groups  delete k8s1-475b6352-default-app01-sol2-svc-canary-8080-8cec9f32 --zone europe-west1-b --quiet
#  - The network_endpoint_group resource 'projects/cicd-platinum-test001/zones/europe-west1-b/networkEndpointGroups/k8s1-475b6352-default-app01-sol2-svc-canary-8080-8cec9f32' is already being used by 'projects/cicd-platinum-test001/global/backendServices/app01-sol2-svc-canary'
# I need to clean deeper :)

# delete backend service "app01-sol2-svc-canary":

# 2. gcloud compute backend-services delete --global "app01-sol2-svc-canary" --quiet
#ERROR: (gcloud.compute.backend-services.delete) Some requests did not succeed:
# - The backend_service resource 'projects/cicd-platinum-test001/global/backendServices/app01-sol2-svc-canary' is already being used by 'projects/cicd-platinum-test001/global/urlMaps/app01-croatia01'

# 3. gcloud compute url-maps delete app01-croatia01-sol2 --quiet
# ERROR: (gcloud.compute.url-maps.delete) Could not fetch resource:
 #- The url_map resource 'projects/cicd-platinum-test001/global/urlMaps/app02-croatia01-sol2' is already being used by 'projects/cicd-platinum-test001/global/targetHttpProxies/app02-croatia01-sol2'

# 4. remove the app02-croatia01-sol2 proxy - this is becoming too fun :)
 #- The url_map resource 'projects/cicd-platinum-test001/global/urlMaps/app02-croatia01-sol2' is already being used by 'projects/cicd-platinum-test001/global/targetHttpProxies/app02-croatia01-sol2'

#gcloud compute target-http-proxies delete app02-croatia01-sol2 --quiet
#ERROR: (gcloud.compute.target-http-proxies.delete) Could not fetch resource:
# - The target_http_proxy resource 'projects/cicd-platinum-test001/global/targetHttpProxies/app02-croatia01-sol2' is already being used by 'projects/cicd-platinum-test001/global/forwardingRules/app02-croatia01-frmt-sol2'

# 5. Ok this is too funny not to write a friction log :)
# gcloud compute forwarding-rules delete app02-croatia01-frmt-sol2 --global --quiet

]# and it WORKS!
}

########################
# Add your code here
########################
DEFAULT_APP="app01"                                # app01 / app02
APP_NAME="${1:-$DEFAULT_APP}"

if [ CLEANUP = "$APP_NAME" ] ; then
    yellow "== $0: CLEANUP =="
    _cleanup_appxx app01
    _cleanup_appxx app02
    exit 0
fi

# Note: Mac doesnt support BASH arrays unless you install bash v5+
_check_your_os_supports_bash_arrays

K8S_APP_SELECTOR="${AppsInterestingHash["$APP_NAME-SELECTOR"]}"
K8S_APP_IMAGE="${AppsInterestingHash["$APP_NAME-IMAGE"]}"

export MYAPP_URLMAP_NAME="$(_urlmap_name_by_app "$APP_NAME" )" # "${APP_NAME}-${URLMAP_NAME_MTSUFFIX}-vm3"  # we have normal and v2
export MYAPP_FWD_RULE="$(_fwd_rule_by_app $APP_NAME)"
#"${APP_NAME}-${FWD_RULE_MTSUFFIX}-fwd-vm3"  # => "vmerge" (vm3)

# MultiTenant solution (parametric in $1)
SOL2_SERVICE_CANARY="$APP_NAME-$DFLT_SOL2_SERVICE_CANARY"    # => appXX-sol2-svc-canary
SOL2_SERVICE_PROD="$APP_NAME-$DFLT_SOL2_SERVICE_PROD"    # => appXX-sol2-svc-prod

# Apply manifests..
solution2_kubectl_apply # kubectk apply

# echo 01a Showing CANARY Endpoints: SOL2_SERVICE_CANARY
# gcloud compute network-endpoint-groups list --filter="$SOL2_SERVICE_CANARY" | lolcat
# echo 01b Showing PROD Endpoints: SOL2_SERVICE_PROD
# gcloud compute network-endpoint-groups list --filter="$SOL2_SERVICE_PROD" | lolcat
gcloud compute forwarding-rules list --filter "$MYAPP_FWD_RULE" | lolcat

MYAPP_IP_FWDRULE=$(gcloud compute forwarding-rules list --filter "$MYAPP_FWD_RULE" | tail -1 | awk '{print $2}')

if "$DEBUG" ; then
    echo "K8S_APP_SELECTOR:    $K8S_APP_SELECTOR"
    echo "K8S_APP_IMAGE:       $K8S_APP_IMAGE"
    echo "SOL2_SERVICE_CANARY: $SOL2_SERVICE_CANARY"
    echo "SOL2_SERVICE_PROD:   $SOL2_SERVICE_PROD"
    echo "MYAPP_FWD_RULE:      $MYAPP_FWD_RULE"
    echo "MYAPP_URLMAP_NAME:   $MYAPP_URLMAP_NAME"
    echo "MYAPP_IP_FWDRULE:    $MYAPP_IP_FWDRULE"
fi
echo
white "Trying $N_TRIES times to curl my host at IP: $MYAPP_IP_FWDRULE [$MYAPP_FWD_RULE]..."
for i in `seq 1 $N_TRIES`; do
    #echo curl -H "Host: www.example.io" "http://$MYAPP_IP_FWDRULE/statusz" 2>/dev/null
    _echodo curl -H "Host: www.example.io" "http://$MYAPP_IP_FWDRULE/statusz" 2>/dev/null
done | tee ".t.$MYAPP_FWD_RULE"

echo 'Stats:'
cat ".t.$MYAPP_FWD_RULE" | sort| uniq -c

echo "Expected values:"
echo "- PROD:   $(green "${PROD_PERCENTAGE}%") -> ~ $(($N_TRIES * $PROD_PERCENTAGE / 100))/$N_TRIES"
echo "- CANARY: $(yellow $CANARY_PERCENTAGE)% -> ~ $(($N_TRIES * $CANARY_PERCENTAGE / 100))/$N_TRIES"
########################
# End of your code here
########################
_allgood_post_script
echo Everything is ok.
