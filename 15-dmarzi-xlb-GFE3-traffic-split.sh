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

# Created with codelabba.rb v.1.5
source .env.sh || _fatal 'Couldnt source this'
set -x
set -e

#HEALTH_CHECK="http-neg-check" 

# These two names need to be aligned with app1/app2 in the k8s.
SERVICE1="svc1-canary90"
SERVICE2="svc2-prod10"
URLMAP_NAME="http-svc9010-lb"
########################
# Add your code here
########################
#
yellow "Deploy the GKE manifests. This needs to happen first as it creates the NEGs which this script depends upon." 

kubectl apply -f k8s/xlb-gfe3-traffic-split/step1/

# create health check for the backends
proceed_if_error_matches "global/healthChecks/http-neg-check' already exists" \
    gcloud compute health-checks create http http-neg-check --port 8080

# create backend for the V1 of the whereami application
proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/backendServices/$SERVICE1' already exists" \
    gcloud compute backend-services create "$SERVICE1" \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --protocol=HTTP \
        --port-name=http \
        --health-checks=http-neg-check \
        --global

# grab the names of the NEGs for $SERVICE1. This should produce 3 lines like this:
# $ gcloud compute network-endpoint-groups list --filter=svc1-canary90
# NAME                                              LOCATION        ENDPOINT_TYPE   SIZE
# k8s1-3072c6bd-canary-svc1-canary90-8080-7bc34067  europe-west6-b  GCE_VM_IP_PORT  0
# k8s1-3072c6bd-canary-svc1-canary90-8080-7bc34067  europe-west6-c  GCE_VM_IP_PORT  1
# k8s1-3072c6bd-canary-svc1-canary90-8080-7bc34067  europe-west6-a  GCE_VM_IP_PORT  0

SVC1_UGLY_NEG_NAME=$(gcloud compute network-endpoint-groups list --filter="$SERVICE1" | grep "$REGION" | awk '{print $1}' | head -1)

echo "NEG1 Found: $(yellow $SVC1_UGLY_NEG_NAME)."

# add the first backend with NEGs from the canary-$SERVICE1 (EXAMPLE BELOW)
# Lets assume the zones are A B C
for ITERATIVE_ZONE in $REGION-a $REGION-b $REGION-c ; do 
  proceed_if_error_matches "Duplicate network endpoint groups in backend service." \
    gcloud compute backend-services add-backend $SERVICE1 \
            --network-endpoint-group=$SVC1_UGLY_NEG_NAME \
            --network-endpoint-group-zone="$ITERATIVE_ZONE" \
            --balancing-mode=RATE \
            --max-rate-per-endpoint=10 \
            --global
done


# create backend for the V2 of the whereami application
proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/backendServices/$SERVICE2' already exists" \
  gcloud compute backend-services create "$SERVICE2" \
    --load-balancing-scheme=EXTERNAL_MANAGED \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=http-neg-check \
    --global

# grab the names of the NEGs for $SERVICE1
#gcloud compute network-endpoint-groups list --filter="canary-$SERVICE2"
#gcloud compute network-endpoint-groups list --filter="$SERVICE1" | grep "$REGION" | awk '{print $1}' | head -1
SVC2_UGLY_NEG_NAME=$(gcloud compute network-endpoint-groups list --filter="$SERVICE2" | grep "$REGION" | awk '{print $1}' | head -1)

echo "NEG2 Found: $(yellow $SVC2_UGLY_NEG_NAME)."

# add the first backend with NEGs from the canary-$SERVICE2 (EXAMPLE BELOW)
for ITERATIVE_ZONE in $REGION-a $REGION-b $REGION-c ; do 
  proceed_if_error_matches "Duplicate network endpoint groups in backend service." \
    gcloud compute backend-services add-backend "$SERVICE2" \
      --network-endpoint-group="$SVC2_UGLY_NEG_NAME" \
      --network-endpoint-group-zone="$ITERATIVE_ZONE" \
      --balancing-mode=RATE \
      --max-rate-per-endpoint=10 \
      --global
done


# Create a default url-map
proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/urlMaps/$URLMAP_NAME' already exists" \
  gcloud compute url-maps create "$URLMAP_NAME" --default-service "$SERVICE1"

# Import traffic-split url-map (from file)
#gcloud compute url-maps import "$URLMAP_NAME" --source='k8s/xlb-gfe3-traffic-split/step2/urlmap-split.yaml'

# Import traffic-split url-map (from STDIN - so templating is trivially obvious)
{ 
# this curly bracket doesnt open subshell. I didnt know! I used normal brackets before today.
# https://unix.stackexchange.com/questions/88490/how-do-you-use-output-redirection-in-combination-with-here-documents-and-cat
cat << END_OF_URLMAP_GCLOUD_YAML_CONFIG
# This comment will be lost in a bash pipe, like tears in the rain...
defaultService: https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendServices/svc1-canary90
hostRules:
- hosts:
  - xlb-gfe3-host.example.io
  - xlb-gfe3.$MY_DOMAIN
  pathMatcher: path-matcher-1
pathMatchers:
- defaultRouteAction:
    faultInjectionPolicy:
      abort:
        httpStatus: 503
        percentage: 100.0
    weightedBackendServices:
    - backendService: https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendServices/svc1-canary90
      weight: 1
  name: path-matcher-1
  routeRules:
  - matchRules:
    - prefixMatch: /
    priority: 1
    routeAction:
      weightedBackendServices:
      - backendService: https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendServices/svc1-canary90
        weight: 89
      - backendService: https://www.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendServices/svc2-prod10
        weight: 11
END_OF_URLMAP_GCLOUD_YAML_CONFIG
} | tee .urlmap.config.yaml && 
  gcloud compute target-http-proxies create "$URLMAP_NAME" --url-map=.urlmap.config.yaml

# TODO(ricc): change 89/11 to 90/10. Just to prove granularity :)
# "$URLMAP_NAME"


# Finalize
gcloud compute forwarding-rules create http-content-rule \
    --load-balancing-scheme=EXTERNAL_MANAGED \
    --global \
    --target-http-proxy="$URLMAP_NAME" \
    --ports=80


# SBAJJATO
#kubectl apply -f k8s/xlb-gfe3-traffic-split/step2/



########################
# End of your code here
########################
#green 'Everything is ok. To use this amazing script, please download it from https://github.com/palladius/sakura'
green 'Everything is ok'
