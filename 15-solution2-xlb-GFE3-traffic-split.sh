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
    echo "$*" >&1
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
    #exit 2352
    _fatal "END(_assert_neg_exists_for_service) \$SVC_UGLY_NEG_NAME ($NEG_ID) is empty. No NEGS found for '$SOL2_SERVICE_NAME'."
  else
    echo "_assert_neg_exists_for_service() NEG $NEG_ID Found: $(yellow $SVC2_UGLY_NEG_NAME)."
  fi
}
function _grab_NEG_name_by_filter() {
  FILTER="$1"
  # DEBUG
  white "[DEBUG] _grab_NEG_name_by_filter('$FILTER')" >&2
  gcloud compute network-endpoint-groups list --filter="$FILTER" | grep "$REGION" | awk '{print $1}' | head -1
}

# Created with codelabba.rb v.1.5
source .env.sh || _fatal 'Couldnt source this'
#set -x
set -e


########################
# Add your code here
########################

########################################################################
# RICC00. ARGV -> vars for MultiAppK8sRefactoring
########################################################################

# These two names need to be aligned with app1/app2 in the k8s.
DEFAULT_APP="app01"                                # app01 / app02
DEFAULT_APP_IMAGE="skaf-app01-python-buildpacks"   # skaf-app01-python-buildpacks // ricc-app02-kuruby-skaffold
APP_NAME="${1:-$DEFAULT_APP}"
K8S_APP_IMAGE="${2:-$DEFAULT_APP_IMAGE}" # "skaf-app01-python-buildpacks"

SOL2_SERVICE1="$APP_NAME-$DFLT_SOL2_SERVICE1"    # => appXX-sol2-svc1-canary
SOL2_SERVICE2="$APP_NAME-$DFLT_SOL2_SERVICE2"    # => appXX-sol2-svc1-prod

# K8S_APP_SELECTOR -> nothing
echo "##############################################"
yellow "WORK IN PROGRESS!! trying to use envsubst to make this easier.."
yellow "Deploy the GKE manifests. This needs to happen first as it creates the NEGs which this script depends upon."
echo "##############################################"

white "01. Showing NEGs for sol2:" # uhm only canary
gcloud compute network-endpoint-groups list  | grep sol2


# RIC001 create health check for the backends
proceed_if_error_matches "global/healthChecks/http-neg-check' already exists" \
    gcloud compute health-checks create http http-neg-check --port 8080

# RIC002 create backend for the V1 of the whereami application
proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/backendServices/$SOL2_SERVICE1' already exists" \
    gcloud compute backend-services create "$SOL2_SERVICE1" \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --protocol=HTTP \
        --port-name=http \
        --health-checks=http-neg-check \
        --global

# RIC003 grab the names of the NEGs for $SOL2_SERVICE1.
# This should produce 3 lines like this:
# $ gcloud compute network-endpoint-groups list --filter=svc1-canary90
# NAME                                              LOCATION        ENDPOINT_TYPE   SIZE
# k8s1-3072c6bd-canary-svc1-canary90-8080-7bc34067  europe-west6-b  GCE_VM_IP_PORT  0
# k8s1-3072c6bd-canary-svc1-canary90-8080-7bc34067  europe-west6-c  GCE_VM_IP_PORT  1
# k8s1-3072c6bd-canary-svc1-canary90-8080-7bc34067  europe-west6-a  GCE_VM_IP_PORT  0

# white "[DEBUG] Showing SORTED NEGs in your region $REGION which might or might not match service '$SOL2_SERVICE1':"
# gcloud compute network-endpoint-groups list --filter="$SOL2_SERVICE1" | grep "$REGION"  | sort | lolcat

SVC1_UGLY_NEG_NAME=$(_grab_NEG_name_by_filter "$SOL2_SERVICE1")
#  echo "NEG possibly Found: $(yellow "$FILTER"). Lets see"
_assert_neg_exists_for_service "$SOL2_SERVICE1" UGLY_NEG1_NAME "$SVC1_UGLY_NEG_NAME"
#                    echodo gcloud compute network-endpoint-groups list --filter="$SOL2_SERVICE1" | grep "$REGION" | awk '{print $1}' | head -1
#SVC1_UGLY_NEG_NAME=$(gcloud compute network-endpoint-groups list --filter="$SOL2_SERVICE1" | grep "$REGION" | awk '{print $1}' | head -1)

#echo "NEG1 Found: $(yellow "$SVC1_UGLY_NEG_NAME")."

# RIC004
# add the first backend with NEGs from the canary-$SOL2_SERVICE1 (EXAMPLE BELOW)
# Lets assume the zones are A B C
#  for ITERATIVE_ZONE in $REGION-a $REGION-b $REGION-c ; do - but some regions dont have A B C so...
_get_zones_by_region "$REGION" | while read ITERATIVE_ZONE ; do
  proceed_if_error_matches "Duplicate network endpoint groups in backend service." \
    gcloud compute backend-services add-backend "$SOL2_SERVICE1" \
            --network-endpoint-group="$SVC1_UGLY_NEG_NAME" \
            --network-endpoint-group-zone="$ITERATIVE_ZONE" \
            --balancing-mode=RATE \
            --max-rate-per-endpoint=10 \
            --global
done


# RIC005 create backend for the V2 of the whereami application
proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/backendServices/$SOL2_SERVICE2' already exists" \
  gcloud compute backend-services create "$SOL2_SERVICE2" \
    --load-balancing-scheme='EXTERNAL_MANAGED' \
    --protocol=HTTP \
    --port-name=http \
    --health-checks='http-neg-check' \
    --global

# RIC006 grab the names of the NEGs for $SOL2_SERVICE1

#white "[DEBUG] Showing SORTED NEGs in your region $REGION which might or might not match service '$SOL2_SERVICE2':"
#SVC1_UGLY_NEG_NAME=$(_grab_NEG_name_by_filter "$SOL2_SERVICE1")
#                     gcloud compute network-endpoint-groups list --filter="$SOL2_SERVICE2" | grep "$REGION" | sort | lolcat
SVC2_UGLY_NEG_NAME=$(_grab_NEG_name_by_filter "$SOL2_SERVICE2" )
echo "NEG2 possibly Found: $(yellow "$SVC2_UGLY_NEG_NAME")."
#2022-07-14: for the first time in my life i could experience a gcloud crash..
_assert_neg_exists_for_service "$SOL2_SERVICE2" UGLY_NEG2_NAME "$SVC2_UGLY_NEG_NAME"


# RIC007 add the first backend with NEGs from the canary-$SOL2_SERVICE2 (EXAMPLE BELOW)
#for ITERATIVE_ZONE in $REGION-a $REGION-b $REGION-c ; do
_get_zones_by_region "$REGION" | while read ITERATIVE_ZONE ; do
  proceed_if_error_matches "Duplicate network endpoint groups in backend service." \
    gcloud compute backend-services add-backend "$SOL2_SERVICE2" \
      --network-endpoint-group="$SVC2_UGLY_NEG_NAME" \
      --network-endpoint-group-zone="$ITERATIVE_ZONE" \
      --balancing-mode=RATE \
      --max-rate-per-endpoint=10 \
      --global
done


# RIC008 Create a default url-map
proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/urlMaps/$URLMAP_NAME' already exists" \
  gcloud compute url-maps create "$URLMAP_NAME" --default-service "$SOL2_SERVICE1"

# Import traffic-split url-map (from file) dmarzi way (obsolete):
#gcloud compute url-maps import "$URLMAP_NAME" --source='k8s/xlb-gfe3-traffic-split/step2/urlmap-split.yaml'

# RIC009b Import traffic-split url-map (from STDIN - so templating is trivially obvious)
{
# this curly bracket doesnt open subshell. I didnt know! I used normal brackets before today.
# https://unix.stackexchange.com/questions/88490/how-do-you-use-output-redirection-in-combination-with-here-documents-and-cat
cat << END_OF_URLMAP_GCLOUD_YAML_CONFIG
# This comment will be lost in a bash pipe, like tears in the rain...
defaultService: https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendServices/$SOL2_SERVICE1
hostRules:
- hosts:
    # This is for ease of troubleshoot
  - sol2-xlb-gfe3.example.io
    # This is for you to use your REAL domain - with Cloud DNS you can just curl the final hostname. Not covered by this demo.
  - sol2-xlb-gfe3.$MY_DOMAIN
  pathMatcher: path-matcher-1
pathMatchers:
- defaultRouteAction:
    faultInjectionPolicy:
      abort:
        httpStatus: 503
        percentage: 100.0
    weightedBackendServices:
    - backendService: https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendServices/$SOL2_SERVICE1
      weight: 1
  name: path-matcher-1
  routeRules:
  - matchRules:
    - prefixMatch: /
    priority: 1
    routeAction:
      weightedBackendServices:
      - backendService: https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendServices/$SOL2_SERVICE1
        weight: 89
      - backendService: https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendServices/$SOL2_SERVICE2
        weight: 11
END_OF_URLMAP_GCLOUD_YAML_CONFIG
} | gcloud compute url-maps import "$URLMAP_NAME" --source=- # --quiet


#proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/targetHttpProxies/http-svc9010-lb' already exists" \

# RIC010 Finalize 1/2
proceed_if_error_matches "already exists" \
  gcloud compute target-http-proxies create "$URLMAP_NAME" --url-map="$URLMAP_NAME"

# TODO(ricc): change 89/11 to 90/10. Just to prove granularity :)
# "$URLMAP_NAME"


# # RIC010 2/2 Finalize
proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/forwardingRules/$FWD_RULE' already exists" \
  gcloud compute forwarding-rules create "$FWD_RULE" \
    --load-balancing-scheme=EXTERNAL_MANAGED \
    --global \
    --target-http-proxy="$URLMAP_NAME" \
    --ports=80

IP_FWDRULE=$(gcloud compute forwarding-rules list --filter "$FWD_RULE" | tail -1 | awk '{print $2}')

# why 20-30? since 90% is a 9vs1 in 10 tries. It takes 20-30 to see a few svc2 hits :)
echo "Now you can try this:             1) IP=$IP_FWDRULE"
echo 'Now you can try this 20-30 times: 2) curl -H "Host: xlb-gfe3-host.example.io" http://$IP/whereami/pod_name'



smart_apply_k8s_templates "$GKE_SOLUTION2_ENVOY_XLB_TRAFFICSPLITTING_SETUP_DIR"

kubectl --context="$GKE_CANARY_CLUSTER_CONTEXT" apply -f "$GKE_SOLUTION2_ENVOY_XLB_TRAFFICSPLITTING_SETUP_DIR/out/"
kubectl --context="$GKE_PROD_CLUSTER_CONTEXT" apply -f "$GKE_SOLUTION2_ENVOY_XLB_TRAFFICSPLITTING_SETUP_DIR/out/"

########################
# End of your code here
########################

# Check everything ok:
bin/kubectl-triune get all | grep "sol1"

green "Everything is ok. Now check your newly created LB for its IP (should be '$IP_FWDRULE')"

# End of your code here
_allgood_post_script
echo Everything is ok.
