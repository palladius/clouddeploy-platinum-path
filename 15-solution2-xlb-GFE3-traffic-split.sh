#!/bin/bash

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
function _get_zones_by_region() {
  #    🐼 gcloud compute zones list | egrep ^europe-west1
  # europe-west1-b             europe-west1             UP
  # europe-west1-d             europe-west1             UP
  # europe-west1-c             europe-west1             UP
  REGION="$1"
  gcloud compute zones list | egrep "^$REGION" | awk '{print $1}'
}
function _assert_neg_exists_for_service() {
  SOL2_SERVICE_NAME="$1"
  NEG_ID="$2"
  SVC_UGLY_NEG_NAME="$3"

  if [ -z "$SVC_UGLY_NEG_NAME" ]; then
    echo "BEGIN \$SVC_UGLY_NEG_NAME ($NEG_ID) is empty. No NEGS found for '$SOL2_SERVICE_NAME'."
    gcloud compute network-endpoint-groups list --filter="$SOL2_SERVICE_NAME" | lolcat
    gcloud compute network-endpoint-groups list --filter="$SOL2_SERVICE_NAME" | grep "$REGION" | awk '{print $1}' | head -1
    _fatal "END(_assert_neg_exists_for_service) \$SVC_UGLY_NEG_NAME ($NEG_ID) is empty. No NEGS found for '$SOL2_SERVICE_NAME'."
  else
    echo "_assert_neg_exists_for_service() NEG $NEG_ID Found: $(yellow $SVC_UGLY_NEG_NAME)."
  fi
}

function _grab_NEG_name_by_filter() {
  FILTER="$1"
  white "[DEBUG] Grabbing NEG name by filter '$FILTER'" >&2
  gcloud compute network-endpoint-groups list --filter="$FILTER" | grep "$REGION" | awk '{print $1}' | head -1
}
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
(kubectl --context="$GKE_CANARY_CLUSTER_CONTEXT" get service | grep sol2
 kubectl --context="$GKE_PROD_CLUSTER_CONTEXT" get service | grep sol2
) | grep canary ||
   red "Looks like no CANARY services are working. Work on your CI/CD pipeline to have working solution2 CANARY Services"

(kubectl --context="$GKE_CANARY_CLUSTER_CONTEXT" get service | grep sol2
 kubectl --context="$GKE_PROD_CLUSTER_CONTEXT" get service | grep sol2
) | grep prod ||
   red "Looks like no PROD services are working. Work on your CI/CD pipeline to have working solution2 PROD Services"

green "It seems you have at least ONE entry for PROD and one entry for CANARY. If not please fix it before going on."

white "01. Showing NEGs for sol2:" # uhm only canary
gcloud compute network-endpoint-groups list  | grep sol2


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
# This should produce 3 lines like this:
# $ gcloud compute network-endpoint-groups list --filter=svcX-canary90
# NAME                                              LOCATION        ENDPOINT_TYPE   SIZE
# k8s1-3072c6bd-canary-svcX-canary90-8080-7bc34067  europe-west6-b  GCE_VM_IP_PORT  0
# k8s1-3072c6bd-canary-svcX-canary90-8080-7bc34067  europe-west6-c  GCE_VM_IP_PORT  1
# k8s1-3072c6bd-canary-svcX-canary90-8080-7bc34067  europe-west6-a  GCE_VM_IP_PORT  0

# white "[DEBUG] Showing SORTED NEGs in your region $REGION which might or might not match service '$SOL2_SERVICE_CANARY':"
# gcloud compute network-endpoint-groups list --filter="$SOL2_SERVICE_CANARY" | grep "$REGION"  | sort | lolcat

#                    echodo gcloud compute network-endpoint-groups list --filter="$SOL2_SERVICE_CANARY" | grep "$REGION" | awk '{print $1}' | head -1
#SVC_UGLY_NEG_NAME_CANARY=$(gcloud compute network-endpoint-groups list --filter="$SOL2_SERVICE_CANARY" | grep "$REGION" | awk '{print $1}' | head -1)

if "$YOU_ARE_REALLY_DESPERATE"; then
  SVC_UGLY_NEG_NAME_CANARY=$(_grab_NEG_name_by_filter "$SOL2_SERVICE_CANARY")
  _assert_neg_exists_for_service "$SOL2_SERVICE_CANARY" SVC_UGLY_NEG_NAME_CANARY "$SVC_UGLY_NEG_NAME_CANARY"
  echo "NEG1 Found: $(yellow "$SVC_UGLY_NEG_NAME_CANARY")."
fi
# RIC004
# add the first backend with NEGs from the canary-$SOL2_SERVICE_CANARY (EXAMPLE BELOW)
# Lets assume the zones are A B C
# _get_zones_by_region "$REGION" | while read ITERATIVE_ZONE ; do
#   proceed_if_error_matches "Duplicate network endpoint groups in backend service." \
#     gcloud compute backend-services add-backend "$SOL2_SERVICE_CANARY" \
#             --network-endpoint-group="$SVC_UGLY_NEG_NAME_CANARY" \
#             --network-endpoint-group-zone="$ITERATIVE_ZONE" \
#             --balancing-mode=RATE \
#             --max-rate-per-endpoint=10 \
#             --global
# done
# Not all Zone have a neg, for instance it could just be n A and B
# gcloud compute network-endpoint-groups list | grep app01-sol2-svc-canary-neg
# app01-sol2-svc-canary-neg                      europe-west1-b  GCE_VM_IP_PORT  0
# app01-sol2-svc-canary-neg                      europe-west1-c  GCE_VM_IP_PORT  1

if "$YOU_ARE_REALLY_DESPERATE"; then
        gcloud compute network-endpoint-groups list | grep "$SOL2_SERVICE_CANARY" |
          while read NEGNAME GREPPED_ZONE ENDPOINT_TYPE SIZE ; do
          proceed_if_error_matches "Duplicate network endpoint groups in backend service." \
            gcloud compute backend-services add-backend "$SOL2_SERVICE_CANARY" \
                    --network-endpoint-group="$SVC_UGLY_NEG_NAME_CANARY" \
                    --network-endpoint-group-zone="$GREPPED_ZONE" \
                    --balancing-mode=RATE \
                    --max-rate-per-endpoint=10 \
                    --global
        done
fi
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

if "$YOU_ARE_REALLY_DESPERATE"; then
      SVC_UGLY_NEG_NAME_PROD=$(_grab_NEG_name_by_filter "$SOL2_SERVICE_PROD" )
      #2022-07-14: for the first time in my life i could experience a gcloud crash..
      _assert_neg_exists_for_service "$SOL2_SERVICE_PROD" SVC_UGLY_NEG_NAME_PROD "$SVC_UGLY_NEG_NAME_PROD"
      echo "NEG2 Found: $(yellow "$SVC_UGLY_NEG_NAME_PROD")."

      # RIC007 add the first backend with NEGs from the canary-$SOL2_SERVICE_PROD (EXAMPLE BELOW)

      #for ITERATIVE_ZONE in $REGION-a $REGION-b $REGION-c ; do
      _get_zones_by_region "$REGION" | while read ITERATIVE_ZONE ; do
        proceed_if_error_matches "Duplicate network endpoint groups in backend service." \
          gcloud compute backend-services add-backend "$SOL2_SERVICE_PROD" \
            --network-endpoint-group="$SVC_UGLY_NEG_NAME_PROD" \
            --network-endpoint-group-zone="$ITERATIVE_ZONE" \
            --balancing-mode=RATE \
            --max-rate-per-endpoint=10 \
            --global
      done
fi

# RIC008 Create a default url-map
proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/urlMaps/$MYAPP_URLMAP_NAME' already exists" \
  gcloud compute url-maps create "$MYAPP_URLMAP_NAME" --default-service "$SOL2_SERVICE_CANARY"

# Import traffic-split url-map (from file) dmarzi way (obsolete):
#gcloud compute url-maps import "$MYAPP_URLMAP_NAME" --source='k8s/xlb-gfe3-traffic-split/step2/urlmap-split.yaml'

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


#proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/targetHttpProxies/http-svc9010-lb' already exists" \

# RIC010 Finalize 1/2

white "RIC010: create UrlMap='$MYAPP_URLMAP_NAME' and FwdRule='$MYAPP_FWD_RULE'"

proceed_if_error_matches "already exists" \
  gcloud compute target-http-proxies create "$MYAPP_URLMAP_NAME" --url-map="$MYAPP_URLMAP_NAME"

# TODO(ricc): change 89/11 to 90/10. Just to prove granularity :)
# "$MYAPP_URLMAP_NAME"


# # RIC010 2/2 Finalize
proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/forwardingRules/$MYAPP_FWD_RULE' already exists" \
  gcloud compute forwarding-rules create "$MYAPP_FWD_RULE" \
    --load-balancing-scheme=EXTERNAL_MANAGED \
    --global \
    --target-http-proxy="$MYAPP_URLMAP_NAME" \
    --ports=80

# Get IP of this Load Balancer
IP_FWDRULE=$(gcloud compute forwarding-rules list --filter "$MYAPP_FWD_RULE" | tail -1 | awk '{print $2}')

# why 20-30? since 90% is a 9vs1 in 10 tries. It takes 20-30 to see a few svc2 hits :)
echo "Now you can try this:             1) IP=$IP_FWDRULE"
echo 'Now you can try this 20-30 times: 2) curl -H "Host: sol2-passepartout.example.io" http://'$IP_FWDRULE'/'

# solution2_kubectl_apply



########################
# End of your code here
########################

# Check everything ok:
bin/kubectl-triune get all | grep "sol2"

green "Everything is ok. Now check your newly created '$APP_NAME' LB for its IP (should be '$IP_FWDRULE')"

# End of your code here
_allgood_post_script
echo Everything is ok.
