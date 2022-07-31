#!/usr/bin/env bash
source .env.sh || fatal "Config doesnt exist please create .env.sh"

VER="1.1"
#set -x
set -e

# 2022-07-23 1.1 changed some names and dflt path to PROD, not canary.
# 2022-07-23 --- BUG: Seems like calling script with app02 drains some serviceds to app01 (!!) so it seems to me like either script 15 or 15b have some
#                     common variables/setups. Yyikes!
# 2022-07-22 1.0 first functional version.

SCRIPT_LOG_FILE=".15bsh.lastStdOutAndErr"
# Logging output both in STD XX and on file
echo "Logging output and error ro: $SCRIPT_LOG_FILE"
exec > >(tee -a "$SCRIPT_LOG_FILE") 2>&1


## This is a test script which needs to be reconciled into the 15.sh.

# _kubectl_on_prod describe service app01-sol2-svc-canary
#   Normal  Create  20m                 neg-controller         Created NEG "k8s1-5d9efb9b-default-app01-sol2-svc-canary-8080-5e454a9e" for default/app01-sol2-svc-canary-k8s1-5d9efb9b-default-app0
# 1-sol2-svc-canary-8080-5e454a9e--/8080-8080-GCE_VM_IP_PORT-L7 in "europe-west1-b".
#   Normal  Create  20m                 neg-controller         Created NEG "k8s1-5d9efb9b-default-app01-sol2-svc-canary-8080-5e454a9e" for default/app01-sol2-svc-canary-k8s1-5d9efb9b-default-app0
# 1-sol2-svc-canary-8080-5e454a9e--/8080-8080-GCE_VM_IP_PORT-L7 in "europe-west1-c".
#   Normal  Create  20m                 neg-controller         Created NEG "k8s1-5d9efb9b-default-app01-sol2-svc-canary-8080-5e454a9e" for default/app01-sol2-svc-canary-k8s1-5d9efb9b-default-app0
# 1-sol2-svc-canary-8080-5e454a9e--/8080-8080-GCE_VM_IP_PORT-L7 in "europe-west1-d".

# PROD cluster, CANARY service
#_kubectl_on_prod describe service app01-sol2-svc-canary | grep neg-controller | grep "Created NEG"
#_kubectl_on_prod get svcneg -o yaml | egrep "name:|networking.gke.io/service-name:" # | grep app01-sol2-svc-canary

# che neg ha app01-sol2-svc-canary?
# => k8s1-5d9efb9b-default-app01-sol2-svc-canary-8080-5e454a9e

DEFAULT_APP="app01"                                # app01 / app02
APP_NAME="${1:-$DEFAULT_APP}"
K8S_APP_SELECTOR="${AppsInterestingHash["$APP_NAME-SELECTOR"]}"
K8S_APP_IMAGE="${AppsInterestingHash["$APP_NAME-IMAGE"]}"

export MYAPP_URLMAP_NAME="${APP_NAME}-$URLMAP_NAME_MTSUFFIX-v2"  # eg: "app02-BLAHBLAH"
export MYAPP_FWD_RULE="${APP_NAME}-${FWD_RULE_MTSUFFIX}-fwd-v2"      # eg: "app02-BLAHBLAH"


_check_your_os_supports_bash_arrays

# uname -a | grep Darwin &&
#   _fatal "Sorry Mac doesnt support bashes yet. Unless you install it view brew and add /opt/homebrew/opt/bash/bin/bash to path :)" ||
#     echo "All good, Bash v5 should support Arrays."
# On Mac, I'm tryiong brew install bash

# function find_neg_by_target_and_cluster() {
#     echo "When you know how it works for one iterate through all four"
#     TARGET="$1"
#     CLUSTER="$2"
# }

white "================================================================"
white  "Note. This script needs to be destroyed and reconciled once it works ;)"
white "APP_NAME:           $APP_NAME"
white "MYAPP_URLMAP_NAME:  $MYAPP_URLMAP_NAME"
white "MYAPP_FWD_RULE:     $MYAPP_FWD_RULE"
white "K8S_APP_SELECTOR:   $K8S_APP_SELECTOR"
white "K8S_APP_IMAGE:      $K8S_APP_IMAGE"
white "FWD_RULE_MTSUFFIX:  $FWD_RULE_MTSUFFIX"
white "URLMAP_NAME_MTSUFFIX: $URLMAP_NAME_MTSUFFIX"
white "BASH:               $BASH"
white "BASH_VERSION:       $BASH_VERSION"
white "================================================================"

# per rimuovere NEG vecchi devi prima rimuovere SERVIZI vecchi
# yellow Show NEG in cluster prod:
# bin/kubectl-prod get svcneg | grep app01-sol2-svc-canary
# bin/kubectl-prod get svcneg | grep app01-sol2-svc-prod
# yellow Show NEG in cluster canary:
# bin/kubectl-canary get svcneg | grep app01-sol2-svc-canary
# bin/kubectl-canary get svcneg | grep app01-sol2-svc-prod
#_kubectl_on_prod get svcneg | grep app01-sol2-svc-canary
#_kubectl_on_prod get svcneg | grep app01-sol2-svc-prod

# k8s1-5d9efb9b-default-app01-sol2-svc-canary-8080-5e454a9e
# dmarz: dentro al nome del NEG hai tutto,


#_kubectl_on_canary describe svcneg/k8s1-a2ee2205-default-app01-sol2-svc-canary-8080-ac75b011

# function get_3negs_by_service_name() {
#     # todo not only prod
#     CLUSTER="$1"
#     _kubectl_on_target "$CLUSTER" get svcneg/k8s1-5d9efb9b-default-app01-sol2-svc-prod-8080-dc533d84 -o json 2>/dev/null |
#         jq -r "select(.metadata.labels.\"networking.gke.io/service-name\" == \"app01-sol2-svc-prod\") .status.networkEndpointGroups[].selfLink , .metadata.labels.\"networking.gke.io/service-name\""

# }

# should all be TRUE :) just deactivating as LAZY
STEP0_APPLY_MANIFESTS="true"
STEP1_CREATE_BACKEND_SERVICES="true"
STEP2_CREATE_LOADS_OF_NEGS="true"
STEP3_CREATE_URLMAP="true"
STEP4_FINAL_HTTPLB="true"
# retrieve NEG in the 3 zones.
# jq 'select(.zone != null) | .zone'
# _kubectl_on_prod get svcneg/k8s1-5d9efb9b-default-app01-sol2-svc-prod-8080-dc533d84 -o json |
#     jq -r "select(.metadata.labels.\"networking.gke.io/service-name\" == \"app01-sol2-svc-prod\") .status.networkEndpointGroups[].selfLink , .metadata.labels.\"networking.gke.io/service-name\""

# yellow now on all:
# _kubectl_on_prod get svcneg -o json 2>/dev/null |
#     jq -r "select(.metadata.labels.\"networking.gke.io/service-name\" == \"app01-sol2-svc-prod\") .status.networkEndpointGroups[].selfLink , .metadata.labels.\"networking.gke.io/service-name\""


if "$STEP0_APPLY_MANIFESTS" ; then

    kubectl --context="$GKE_CANARY_CLUSTER_CONTEXT" apply -k "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.4.3"
    kubectl --context="$GKE_PROD_CLUSTER_CONTEXT" apply -k "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.4.3"

    solution2_kubectl_apply "$APP_NAME" # kubectl apply buridone :)
fi

if "$STEP1_CREATE_BACKEND_SERVICES"; then
    for TYPE_OF_TRAFFIC in canary prod ; do
        SERVICE_NAME="$APP_NAME-sol2-svc-$TYPE_OF_TRAFFIC"
        proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/backendServices/$SERVICE_NAME' already exists" \
            gcloud compute backend-services create "$SERVICE_NAME" \
                --load-balancing-scheme='EXTERNAL_MANAGED' \
                --protocol=HTTP \
                --port-name=http \
                --health-checks='http-neg-check' \
                --global
    done
fi
# $APP_NAME
    if "$STEP2_CREATE_LOADS_OF_NEGS" ; then
    for MY_CLUSTER in canary prod ; do
        for TYPE_OF_TRAFFIC in canary prod ; do
            SERVICE_NAME="$APP_NAME-sol2-svc-$TYPE_OF_TRAFFIC"
            yellow "+ MY_CLUSTER=$MY_CLUSTER :: TYPE_OF_TRAFFIC=$TYPE_OF_TRAFFIC SERVICE_NAME:$SERVICE_NAME"
            NEG_NAME=$(_kubectl_on_target "$MY_CLUSTER" get svcneg 2>/dev/null | grep "$SERVICE_NAME" | awk '{print $1}')
            echo "[$MY_CLUSTER] 1. NEG NAME: '${NEG_NAME}'"
            echo "[$MY_CLUSTER] 2. Lets now iterate through the N zones:"
            _kubectl_on_target "$MY_CLUSTER" get "svcneg/$NEG_NAME" -o json  2>/dev/null |
                jq -r "select(.metadata.labels.\"networking.gke.io/service-name\" == \"$SERVICE_NAME\") .status.networkEndpointGroups[].selfLink " | # , .metadata.labels.\"networking.gke.io/service-name\"
    #            jq -r "select(.metadata.labels.\"networking.gke.io/service-name\" == \"app01-sol2-svc-prod\") .status.networkEndpointGroups[].selfLink " | # , .metadata.labels.\"networking.gke.io/service-name\"
        # https://www.googleapis.com/compute/v1/projects/cicd-platinum-test003/zones/europe-west1-b/networkEndpointGroups/k8s1-5d9efb9b-default-app01-sol2-svc-prod-8080-dc533d84
        # https://www.googleapis.com/compute/v1/projects/cicd-platinum-test003/zones/europe-west1-c/networkEndpointGroups/k8s1-5d9efb9b-default-app01-sol2-svc-prod-8080-dc533d84
        # https://www.googleapis.com/compute/v1/projects/cicd-platinum-test003/zones/europe-west1-d/networkEndpointGroups/k8s1-5d9efb9b-default-app01-sol2-svc-prod-8080-dc533d84
                    while read NEG_RESOURCE ; do
                        #_deb NEG_RESOURCE=$NEG_RESOURCE
                        EXTRACTED_ZONE=$(echo $NEG_RESOURCE | cut -f 9 -d/ ) # changes
                        EXTRACTED_NEG_NAME=$(echo $NEG_RESOURCE | cut -f 11 -d/ )   # always the same
                        #_deb "TODO stuff with it: zone=$EXTRACTED_ZONE NEG=$EXTRACTED_NEG_NAME"
                        #echo TODO after dmarzi ok
                        proceed_if_error_matches "Duplicate network endpoint groups in backend service." \
                        gcloud compute backend-services add-backend "$SERVICE_NAME" \
                            --network-endpoint-group="$EXTRACTED_NEG_NAME" \
                            --network-endpoint-group-zone="$EXTRACTED_ZONE" \
                            --balancing-mode=RATE \
                            --max-rate-per-endpoint=10 \
                            --global
                    done
        #_kubectl_on_target canary get svcneg
        done
    done
fi


if "$STEP3_CREATE_URLMAP" ; then
    APPDEPENDENT_SOL2_SERVICE_PROD="$APP_NAME-sol2-svc-prod"
    APPDEPENDENT_SOL2_SERVICE_CANARY="$APP_NAME-sol2-svc-canary"

    proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/urlMaps/$MYAPP_URLMAP_NAME' already exists" \
        gcloud compute url-maps create "$MYAPP_URLMAP_NAME" --default-service "$APPDEPENDENT_SOL2_SERVICE_PROD"


    { cat << END_OF_URLMAP_GCLOUD_YAML_CONFIG
# This comment will be lost in a bash pipe, like tears in the rain...
defaultService: https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendServices/$APPDEPENDENT_SOL2_SERVICE_PROD
hostRules:
- hosts:
    # This is for ease of troubleshoot
  - ${APP_NAME}-sol2-xlb-gfe3.example.io
    # This is for you to use your REAL domain - with Cloud DNS you can just curl the final hostname. Not covered by this demo.
  - ${APP_NAME}-sol2-xlb-gfe3.$MY_DOMAIN
    # this is part of the new Passepartout philosophy for ease of troubleshooting
  - sol2-passepartout.example.io
  - passepartout.example.io
  - www.example.io
  pathMatcher: path-matcher-1
pathMatchers:
- defaultRouteAction:
    faultInjectionPolicy:
      abort:
        httpStatus: 503
        percentage: 100.0
    weightedBackendServices:
    - backendService: https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendServices/$APPDEPENDENT_SOL2_SERVICE_CANARY
      weight: 1
  # Note this will stop wprking in the future. good luck with STDIN with this error:
  # WARNING: The name of the Url Map must match the value of the 'name' attribute in the YAML file. Future versions of gcloud will fail with an error.
  name: path-matcher-1
  routeRules:
  - matchRules:
    - prefixMatch: /
    priority: 1
    routeAction:
      weightedBackendServices:
      - backendService: https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendServices/$APPDEPENDENT_SOL2_SERVICE_CANARY
        weight: 22
      - backendService: https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendServices/$APPDEPENDENT_SOL2_SERVICE_PROD
        weight: 78
END_OF_URLMAP_GCLOUD_YAML_CONFIG
} | tee k8s/solution2-xlb-gfe3-traffic-split/.tmp-urlmap-v2.yaml
    cat k8s/solution2-xlb-gfe3-traffic-split/.tmp-urlmap-v2.yaml | lolcat
    cat k8s/solution2-xlb-gfe3-traffic-split/.tmp-urlmap-v2.yaml |
        # take from STDIN
        gcloud compute url-maps import "$MYAPP_URLMAP_NAME" --source=- --quiet
fi

if "$STEP4_FINAL_HTTPLB"; then

    white "RIC010: create UrlMap='$MYAPP_URLMAP_NAME' and FwdRule='$MYAPP_FWD_RULE'"

    proceed_if_error_matches "already exists" \
        gcloud compute target-http-proxies create "$MYAPP_URLMAP_NAME" --url-map="$MYAPP_URLMAP_NAME"

    proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/forwardingRules/$MYAPP_FWD_RULE' already exists" \
      gcloud compute forwarding-rules create "$MYAPP_FWD_RULE" \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --global \
        --target-http-proxy="$MYAPP_URLMAP_NAME" \
        --ports=80

fi
