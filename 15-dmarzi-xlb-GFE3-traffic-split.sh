#!/bin/bash

function _fatal() {
    echo "$*" >&1
    exit 42
}

# Created with codelabba.rb v.1.5
source .env.sh || _fatal 'Couldnt source this'
set -x
set -e

#HEALTH_CHECK="http-neg-check"
SERVICE1="svc1-canary"
SERVICE2="svc2-prod"
########################
# Add your code here
########################
#
#Deploy the applications as usual

# create health check for the backends
proceed_if_error_matches "global/healthChecks/http-neg-check' already exists" \
    gcloud compute health-checks create http http-neg-check --port 8080

# create backend for the V1 of the whereami application
proceed_if_error_matches "The resource 'projects/$PROJECT_ID/global/backendServices/$SERVICE1' already exists" \
    gcloud compute backend-services create $SERVICE1 \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --protocol=HTTP \
        --port-name=http \
        --health-checks=http-neg-check \
        --global

# grab the names of the NEGs for $SERVICE1
gcloud compute network-endpoint-groups list --filter="canary-$SERVICE1"

exit 0

# add the first backend with NEGs from the canary-$SERVICE1 (EXAMPLE BELOW)
gcloud compute backend-services add-backend $SERVICE1 \
        --network-endpoint-group=k8s1-8ac5360b-canary-$SERVICE1-8080-3fe8fae3 \
        --network-endpoint-group-zone=$REGION-b \
        --balancing-mode=RATE \
        --max-rate-per-endpoint=10 \
        --global

gcloud compute backend-services add-backend $SERVICE1 \
        --network-endpoint-group=k8s1-8ac5360b-canary-$SERVICE1-8080-3fe8fae3 \
        --network-endpoint-group-zone=$REGION-c \
        --balancing-mode=RATE \
        --max-rate-per-endpoint=10 \
        --global

gcloud compute backend-services add-backend $SERVICE1 \
        --network-endpoint-group=k8s1-8ac5360b-canary-$SERVICE1-8080-3fe8fae3 \
        --network-endpoint-group-zone=$REGION-a \
        --balancing-mode=RATE \
        --max-rate-per-endpoint=10 \
        --global

# create backend for the V2 of the whereami application
gcloud compute backend-services create $SERVICE2 \
    --load-balancing-scheme=EXTERNAL_MANAGED \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=http-neg-check \
    --global

# grab the names of the NEGs for $SERVICE1
gcloud compute network-endpoint-groups list --filter="canary-$SERVICE2"

# add the first backend with NEGs from the canary-$SERVICE2 (EXAMPLE BELOW)
gcloud compute backend-services add-backend $SERVICE2 \
        --network-endpoint-group=k8s1-8ac5360b-canary-$SERVICE2-8080-a4d133a9 \
        --network-endpoint-group-zone=$REGION-b \
        --balancing-mode=RATE \
        --max-rate-per-endpoint=10 \
        --global

gcloud compute backend-services add-backend $SERVICE2 \
        --network-endpoint-group=k8s1-8ac5360b-canary-$SERVICE2-8080-a4d133a9 \
        --network-endpoint-group-zone=$REGION-c \
        --balancing-mode=RATE \
        --max-rate-per-endpoint=10 \
        --global

gcloud compute backend-services add-backend $SERVICE2 \
        --network-endpoint-group=k8s1-8ac5360b-canary-$SERVICE2-8080-a4d133a9 \
        --network-endpoint-group-zone=$REGION-a \
        --balancing-mode=RATE \
        --max-rate-per-endpoint=10 \
        --global

# Create a default url-map
gcloud compute url-maps create http-whereami-lb --default-service $SERVICE1

# Import traffic-split url-map
gcloud compute url-maps import http-whereami-lb --source=urlmap-split.yaml

# Finalize
gcloud compute target-http-proxies create http-whereami-lb --url-map=http-whereami-lb
gcloud compute forwarding-rules create http-content-rule \
    --load-balancing-scheme=EXTERNAL_MANAGED \
    --global \
    --target-http-proxy=http-whereami-lb  \
    --ports=80







########################
# End of your code here
########################
#green 'Everything is ok. To use this amazing script, please download it from https://github.com/palladius/sakura'
echo 'Everything is ok'
