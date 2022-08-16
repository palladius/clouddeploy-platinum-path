#!/bin/bash

# 015 Merge TODO
# 1. verify 15 script
# 2. verify 15b script
# 3. remove s**t
# 4. git mv and everything.

################################################################################
# 2022-08-16 BigMerge - Script1 (15-solution2-xlb-GFE3-traffic-split.sh)
################################################################################

################################################################################
# WHAT IS THIS?!?
################################################################################
# This script ripercurs the footsteps of dmarzi@ script in `k8s/xlb-gfe3-traffic-split/`
# It's a bit 'dirty' since it requires both k8s manifests and gcloud commands to be
# glued together but is currently the ONLY solution to do Traffic Splitting with
# external-facing public IP Load Balancing. When Gateway API will support TS on
# ELB as well (currently only ILB are backed up Envoy) this effort will become
# useless but is still put here as an example to demonstrate the TS functionality.
################################################################################

function _fatal() {
    echo "[FATAL] $*" >&1
    exit 42
}
# function _get_zones_by_region() {
#   #    🐼 gcloud compute zones list | egrep ^europe-west1
#   # europe-west1-b             europe-west1             UP
#   # europe-west1-d             europe-west1             UP
#   # europe-west1-c             europe-west1             UP
#   REGION="$1"
#   gcloud compute zones list | egrep "^$REGION" | awk '{print $1}'
# }
# function _assert_neg_exists_for_service() {
#   SOL2_SERVICE_NAME="$1"
#   NEG_ID="$2"
#   SVC_UGLY_NEG_NAME="$3"

#   if [ -z "$SVC_UGLY_NEG_NAME" ]; then
#     echo "BEGIN \$SVC_UGLY_NEG_NAME ($NEG_ID) is empty. No NEGS found for '$SOL2_SERVICE_NAME'."
#     gcloud compute network-endpoint-groups list --filter="$SOL2_SERVICE_NAME" | lolcat
#     gcloud compute network-endpoint-groups list --filter="$SOL2_SERVICE_NAME" | grep "$REGION" | awk '{print $1}' | head -1
#     _fatal "END(_assert_neg_exists_for_service) \$SVC_UGLY_NEG_NAME ($NEG_ID) is empty. No NEGS found for '$SOL2_SERVICE_NAME'."
#   else
#     echo "_assert_neg_exists_for_service() NEG $NEG_ID Found: $(yellow $SVC_UGLY_NEG_NAME)."
#   fi
# }

# function _grab_NEG_name_by_filter() {
#   FILTER="$1"
#   white "[DEBUG] Grabbing NEG name by filter '$FILTER'" >&2
#   gcloud compute network-endpoint-groups list --filter="$FILTER" | grep "$REGION" | awk '{print $1}' | head -1
# }
# solution2_kubectl_apply() {
#   smart_apply_k8s_templates "$GKE_SOLUTION2_ENVOY_XLB_TRAFFICSPLITTING_SETUP_DIR"

#   # If you changed some name and you get IMMUTABLE error, try to destroy the same resource before:
#   # eg, bin/kubectl-prod delete deployments/app01-sol2-svc-canary
#   #kubectl --context="$GKE_CANARY_CLUSTER_CONTEXT" delete "Deployments/$SOL2_SERVICE_CANARY"
#   #kubectl --context="$GKE_CANARY_CLUSTER_CONTEXT" delete "Deployments/$SOL2_SERVICE_PROD"
#   bin/kubectl-canary apply -f "$GKE_SOLUTION2_ENVOY_XLB_TRAFFICSPLITTING_SETUP_DIR/out/"
#   bin/kubectl-prod    apply -f "$GKE_SOLUTION2_ENVOY_XLB_TRAFFICSPLITTING_SETUP_DIR/out/"
# }


#https://www.unix.com/shell-programming-and-scripting/183865-automatically-send-stdout-stderror-file-well-screen-but-without-using-tee.html
SCRIPT_LOG_FILE=".15sh.lastStdOutAndErr"
# Logging output both in STD XX and on file
echo "Logging output and error ro: $SCRIPT_LOG_FILE"
exec > >(tee -a "$SCRIPT_LOG_FILE") 2>&1

# Created with codelabba.rb v.1.5
source .env.sh || _fatal 'Couldnt source this'
#set -x
set -e

# Now script 15b is taking care of everyting. In want to keep the code working but until its here uncommented
# I also want to be able to get i back, hence the desperate diciture.
export YOU_ARE_REALLY_DESPERATE="false"

########################
# Add your code here
########################

########################################################################
# RICC00. ARGV -> vars for MultiAppK8sRefactoring
########################################################################

# These two names need to be aligned with app1/app2 in the k8s.
# 01a Magic defaults
DEFAULT_APP="app01"                                # app01 / app02
DEFAULT_APP_SELECTOR="app01-kupython"              # app01-kupython / app02-kuruby
DEFAULT_APP_IMAGE="skaf-app01-python-buildpacks"   # skaf-app01-python-buildpacks // ricc-app02-kuruby-skaffold
# 01b Magic Values
APP_NAME="${1:-$DEFAULT_APP}"
#K8S_APP_SELECTOR="${2:-$DEFAULT_APP_SELECTOR}"
#K8S_APP_IMAGE="${3:-$DEFAULT_APP_IMAGE}"#
# Default from Magic Hash Array :)
K8S_APP_SELECTOR="${AppsInterestingHash["$APP_NAME-SELECTOR"]}"
K8S_APP_IMAGE="${AppsInterestingHash["$APP_NAME-IMAGE"]}"


# MultiTenant solution (parametric in $1)
SOL2_SERVICE_CANARY="$APP_NAME-$DFLT_SOL2_SERVICE_CANARY"    # => appXX-sol2-svc-canary
SOL2_SERVICE_PROD="$APP_NAME-$DFLT_SOL2_SERVICE_PROD"        # => appXX-sol2-svc-prod

# Now that I know APPXX I can do this:
export MYAPP_URLMAP_NAME="${APP_NAME}-$URLMAP_NAME_MTSUFFIX"  # eg: "app02-BLAHBLAH"
export MYAPP_FWD_RULE="${APP_NAME}-${FWD_RULE_MTSUFFIX}"      # eg: "app02-BLAHBLAH"

# K8S_APP_SELECTOR -> nothing
echo "##############################################"
green "As of 18jul22 I declare this script as WORKING."
#yellow "WORK IN PROGRESS! on 17jul22 I was finally able to get to the end of this script in its entirety after the huge multi-tennant refactor"
#yellow "TODO(ricc): everything is multi-tennant except the FWD RULE part. Shouls have app01/02 in it.."
#yellow "Deploy the GKE manifests. This needs to happen first as it creates the NEGs which this script depends upon."
echo "MYAPP_URLMAP_NAME:   $MYAPP_URLMAP_NAME"
echo "MYAPP_FWD_RULE:      $MYAPP_FWD_RULE"
echo "K8S_APP_SELECTOR:    $K8S_APP_SELECTOR"
echo "K8S_APP_IMAGE:       $K8S_APP_IMAGE"
echo "SOL2_SERVICE_CANARY: $SOL2_SERVICE_CANARY"
echo "SOL2_SERVICE_PROD:   $SOL2_SERVICE_PROD"
echo "##############################################"

# Cleaning old templates in case you've renamed something so i dont tear up WO resources with sightly different names
make clean

kubectl --context="$GKE_CANARY_CLUSTER_CONTEXT" apply -k "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.4.3"
kubectl --context="$GKE_PROD_CLUSTER_CONTEXT" apply -k "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.4.3"

solution2_kubectl_apply # kubectl apply buridone :)

red "00Warning. I've noticed after 7d of failures that as a prerequisite for this to work you need the k8s deployments correctly named. Im going to make this as a prerequisite"
white "00. Check that Canary and Prod have made it correctly to your k8s systems via some kubectl command:"
# (kubectl --context="$GKE_CANARY_CLUSTER_CONTEXT" get service | grep sol2
#  kubectl --context="$GKE_PROD_CLUSTER_CONTEXT" get service | grep sol2
# )
bin/kubectl-canary-and-prod get service | grep sol2 | grep canary ||
   red "Looks like no CANARY services are working. Work on your CI/CD pipeline to have working solution2 CANARY Services"

(kubectl --context="$GKE_CANARY_CLUSTER_CONTEXT" get service | grep sol2
 kubectl --context="$GKE_PROD_CLUSTER_CONTEXT" get service | grep sol2
) | grep prod ||
   red "Looks like no PROD services are working. Work on your CI/CD pipeline to have working solution2 PROD Services"

green "It seems you have at least ONE entry for PROD and one entry for CANARY. If not please fix it before going on."

#white "01. Showing NEGs for sol2:" # uhm only canary
#gcloud compute network-endpoint-groups list  | grep sol2


# RIC001 create health check for the backends
proceed_if_error_matches "global/healthChecks/http-neg-check' already exists" \
    gcloud compute health-checks create http http-neg-check --port 8080

# RIC002 create backend for the V1 of the whereami application
proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/backendServices/$SOL2_SERVICE_CANARY' already exists" \
    gcloud compute backend-services create "$SOL2_SERVICE_CANARY" \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --protocol=HTTP \
        --port-name=http \
        --health-checks=http-neg-check \
        --global

proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/backendServices/$SOL2_SERVICE_PROD' already exists" \
    gcloud compute backend-services create "$SOL2_SERVICE_PROD" \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --protocol=HTTP \
        --port-name=http \
        --health-checks=http-neg-check \
        --global


# RIC003 grab the names of the NEGs for $SOL2_SERVICE_CANARY.

if "$YOU_ARE_REALLY_DESPERATE"; then
  # SVC_UGLY_NEG_NAME_CANARY=$(_grab_NEG_name_by_filter "$SOL2_SERVICE_CANARY")
  # _assert_neg_exists_for_service "$SOL2_SERVICE_CANARY" SVC_UGLY_NEG_NAME_CANARY "$SVC_UGLY_NEG_NAME_CANARY"
  # echo "NEG1 Found: $(yellow "$SVC_UGLY_NEG_NAME_CANARY")."
  echo -en ''
fi
# RIC004


# if "$YOU_ARE_REALLY_DESPERATE"; then
#         gcloud compute network-endpoint-groups list | grep "$SOL2_SERVICE_CANARY" |
#           while read NEGNAME GREPPED_ZONE ENDPOINT_TYPE SIZE ; do
#           proceed_if_error_matches "Duplicate network endpoint groups in backend service." \
#             gcloud compute backend-services add-backend "$SOL2_SERVICE_CANARY" \
#                     --network-endpoint-group="$SVC_UGLY_NEG_NAME_CANARY" \
#                     --network-endpoint-group-zone="$GREPPED_ZONE" \
#                     --balancing-mode=RATE \
#                     --max-rate-per-endpoint=10 \
#                     --global
#         done
# fi

# RIC005 create backend for the V2 of the whereami application.
# [Multitenancy] 17jul22 bring this command UP since here it fails. well i'll leave it twice as no biggie..
proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/backendServices/$SOL2_SERVICE_PROD' already exists" \
  gcloud compute backend-services create "$SOL2_SERVICE_PROD" \
    --load-balancing-scheme='EXTERNAL_MANAGED' \
    --protocol=HTTP \
    --port-name=http \
    --health-checks='http-neg-check' \
    --global

# RIC006 grab the names of the NEGs for $SOL2_SERVICE_CANARY

# if "$YOU_ARE_REALLY_DESPERATE"; then
#       SVC_UGLY_NEG_NAME_PROD=$(_grab_NEG_name_by_filter "$SOL2_SERVICE_PROD" )
#       #2022-07-14: for the first time in my life i could experience a gcloud crash..
#       _assert_neg_exists_for_service "$SOL2_SERVICE_PROD" SVC_UGLY_NEG_NAME_PROD "$SVC_UGLY_NEG_NAME_PROD"
#       echo "NEG2 Found: $(yellow "$SVC_UGLY_NEG_NAME_PROD")."

#       # RIC007 add the first backend with NEGs from the canary-$SOL2_SERVICE_PROD (EXAMPLE BELOW)

#       #for ITERATIVE_ZONE in $REGION-a $REGION-b $REGION-c ; do
#       _get_zones_by_region "$REGION" | while read ITERATIVE_ZONE ; do
#         proceed_if_error_matches "Duplicate network endpoint groups in backend service." \
#           gcloud compute backend-services add-backend "$SOL2_SERVICE_PROD" \
#             --network-endpoint-group="$SVC_UGLY_NEG_NAME_PROD" \
#             --network-endpoint-group-zone="$ITERATIVE_ZONE" \
#             --balancing-mode=RATE \
#             --max-rate-per-endpoint=10 \
#             --global
#       done
# fi

# RIC008 Create a default url-map
proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/urlMaps/$MYAPP_URLMAP_NAME' already exists" \
  gcloud compute url-maps create "$MYAPP_URLMAP_NAME" --default-service "$SOL2_SERVICE_CANARY"

# Import traffic-split url-map (from file) dmarzi way (obsolete):
#gcloud compute url-maps import "$MYAPP_URLMAP_NAME" --source='k8s/xlb-gfe3-traffic-split/step2/urlmap-split.yaml'

if "$YOU_ARE_REALLY_DESPERATE"; then
# RIC009b Import traffic-split url-map (from STDIN - so templating is trivially obvious)
{
# this curly bracket doesnt open subshell. I didnt know! I used normal brackets before today.
# https://unix.stackexchange.com/questions/88490/how-do-you-use-output-redirection-in-combination-with-here-documents-and-cat
cat << END_OF_URLMAP_GCLOUD_YAML_CONFIG
# This comment will be lost in a bash pipe, like tears in the rain...
defaultService: https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendServices/$SOL2_SERVICE_CANARY
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
  pathMatcher: path-matcher-dmarzi
pathMatchers:
- defaultRouteAction:
    faultInjectionPolicy:
      abort:
        httpStatus: 503
        percentage: 100.0
    weightedBackendServices:
    - backendService: https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendServices/$SOL2_SERVICE_CANARY
      weight: 1
  # Note this will stop wprking in the future. good luck with STDIN with this error:
  # WARNING: The name of the Url Map must match the value of the 'name' attribute in the YAML file. Future versions of gcloud will fail with an error.
  name: path-matcher-dmarzi
  routeRules:
  - matchRules:
    - prefixMatch: /
    priority: 1
    routeAction:
      weightedBackendServices:
      - backendService: https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendServices/$SOL2_SERVICE_CANARY
        weight: 22
      - backendService: https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendServices/$SOL2_SERVICE_PROD
        weight: 78
END_OF_URLMAP_GCLOUD_YAML_CONFIG
} | tee k8s/solution2-xlb-gfe3-traffic-split/.tmp-urlmap.yaml |
gcloud compute url-maps import "$MYAPP_URLMAP_NAME" --source=- --quiet

fi

# RIC010 Finalize 1/2

# white "RIC010: create UrlMap='$MYAPP_URLMAP_NAME' and FwdRule='$MYAPP_FWD_RULE'"

# proceed_if_error_matches "already exists" \
#   gcloud compute target-http-proxies create "$MYAPP_URLMAP_NAME" --url-map="$MYAPP_URLMAP_NAME"



# # # RIC010 2/2 Finalize
# proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/forwardingRules/$MYAPP_FWD_RULE' already exists" \
#   gcloud compute forwarding-rules create "$MYAPP_FWD_RULE" \
#     --load-balancing-scheme=EXTERNAL_MANAGED \
#     --global \
#     --target-http-proxy="$MYAPP_URLMAP_NAME" \
#     --ports=80

# Get IP of this Load Balancer
IP_FWDRULE=$(gcloud compute forwarding-rules list --filter "$MYAPP_FWD_RULE" | tail -1 | awk '{print $2}')

# why 20-30? since 90% is a 9vs1 in 10 tries. It takes 20-30 to see a few svc2 hits :)
yellow "Now you can try this:             1) IP=$IP_FWDRULE"
yellow 'Now you can try this 20-30 times: 2) curl -H "Host: sol2-passepartout.example.io" http://'$IP_FWDRULE'/'
yellow ".. or simply call bin/curl-them-all"


########################
# End of your code here
########################

# Check everything ok:
#bin/kubectl-triune get all | grep "sol2"

green "Everything is ok. Now check your newly created '$APP_NAME' LB for its IP (should be '$IP_FWDRULE')"

# End of your code here
_allgood_post_script
echo Everything is ok.


################################################################################
# 2022-08-16 BigMerge - Script2 (15b-smart-NEG-finder.sh)
################################################################################


#VER="1.1"
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
white "  Note. This script needs to be destroyed and reconciled once it works ;)"
white "APP_NAME:             $APP_NAME"
white "MYAPP_URLMAP_NAME:    $MYAPP_URLMAP_NAME"
white "MYAPP_FWD_RULE:       $MYAPP_FWD_RULE"
white "K8S_APP_SELECTOR:     $K8S_APP_SELECTOR"
white "K8S_APP_IMAGE:        $K8S_APP_IMAGE"
white "FWD_RULE_MTSUFFIX:    $FWD_RULE_MTSUFFIX"
white "URLMAP_NAME_MTSUFFIX: $URLMAP_NAME_MTSUFFIX"
white "BASH:                 $BASH"
white "BASH_VERSION:         $BASH_VERSION"
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
