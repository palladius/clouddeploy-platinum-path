#!/bin/bash

DEFAULT_N_TRIES="15"
N_TRIES="$DEFAULT_N_TRIES"
#N_TRIES=${1:-$DEFAULT_N_TRIES}

# Created with codelabba.rb v.1.5
source .env.sh || _fatal 'Couldnt source this'
#set -x
set -e

########################
# Add your code here
########################
DEFAULT_APP="app01"                                # app01 / app02
APP_NAME="${1:-$DEFAULT_APP}"

# Note: Mac doesnt support BASH arrays unless you install bash v5+
_check_your_os_supports_bash_arrays

K8S_APP_SELECTOR="${AppsInterestingHash["$APP_NAME-SELECTOR"]}"
K8S_APP_IMAGE="${AppsInterestingHash["$APP_NAME-IMAGE"]}"
SMART_EGREP=${AppsInterestingHash["$APP_NAME-WEB_EGREP"]} # useless now:)

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
    echo "SMART_EGREP:         $SMART_EGREP"
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
    # | egrep -i 'statusz' # egrep "$SMART_EGREP" | head -1
done
echo ''


########################
# End of your code here
########################
_allgood_post_script
echo Everything is ok.
