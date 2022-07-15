## ricc reshuffle

I changed name of resources to make sure they work from the ground up.

Renames:

* `whereami-v1` -> svc1-canary90 -> $APPNAME-sol2-svc1-canary"  -> $APPNAME-sol2-svc-canary
* `whereami-v2` -> svc2-prod10   -> $APPNAME-sol2-svc2-prod"   ->  $APPNAME-sol2-svc-prod

## dmarzi instructions

# Deploy the applications as usual

#kubectl create namespace canary
kubectl apply -f k8s/xlb-gfe3-traffic-split/

# create health check for the backends
gcloud compute health-checks create http http-neg-check --port 8080


# create backend for the V1 of the whereami application
gcloud compute backend-services create whereami-v1 \
    --load-balancing-scheme=EXTERNAL_MANAGED \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=http-neg-check \
    --global

# grab the names of the NEGs for whereami-v1
gcloud compute network-endpoint-groups list --filter="canary-whereami-v1"

# add the first backend with NEGs from the canary-whereami-v1 (EXAMPLE BELOW)
gcloud compute backend-services add-backend whereami-v1 \
        --network-endpoint-group=k8s1-8ac5360b-canary-whereami-v1-8080-3fe8fae3 \
        --network-endpoint-group-zone=europe-north1-b \
        --balancing-mode=RATE \
        --max-rate-per-endpoint=10 \
        --global

gcloud compute backend-services add-backend whereami-v1 \
        --network-endpoint-group=k8s1-8ac5360b-canary-whereami-v1-8080-3fe8fae3 \
        --network-endpoint-group-zone=europe-north1-c \
        --balancing-mode=RATE \
        --max-rate-per-endpoint=10 \
        --global

gcloud compute backend-services add-backend whereami-v1 \
        --network-endpoint-group=k8s1-8ac5360b-canary-whereami-v1-8080-3fe8fae3 \
        --network-endpoint-group-zone=europe-north1-a \
        --balancing-mode=RATE \
        --max-rate-per-endpoint=10 \
        --global

# create backend for the V2 of the whereami application
gcloud compute backend-services create whereami-v2 \
    --load-balancing-scheme=EXTERNAL_MANAGED \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=http-neg-check \
    --global

# grab the names of the NEGs for whereami-v1
gcloud compute network-endpoint-groups list --filter="canary-whereami-v2"

# add the first backend with NEGs from the canary-whereami-v2 (EXAMPLE BELOW)
gcloud compute backend-services add-backend whereami-v2 \
        --network-endpoint-group=k8s1-8ac5360b-canary-whereami-v2-8080-a4d133a9 \
        --network-endpoint-group-zone=europe-north1-b \
        --balancing-mode=RATE \
        --max-rate-per-endpoint=10 \
        --global

gcloud compute backend-services add-backend whereami-v2 \
        --network-endpoint-group=k8s1-8ac5360b-canary-whereami-v2-8080-a4d133a9 \
        --network-endpoint-group-zone=europe-north1-c \
        --balancing-mode=RATE \
        --max-rate-per-endpoint=10 \
        --global

gcloud compute backend-services add-backend whereami-v2 \
        --network-endpoint-group=k8s1-8ac5360b-canary-whereami-v2-8080-a4d133a9 \
        --network-endpoint-group-zone=europe-north1-a \
        --balancing-mode=RATE \
        --max-rate-per-endpoint=10 \
        --global

# Create a default url-map
gcloud compute url-maps create http-whereami-lb --default-service whereami-v1

# Import traffic-split url-map
gcloud compute url-maps import http-whereami-lb --source=urlmap-split.yaml

# Finalize
gcloud compute target-http-proxies create http-whereami-lb --url-map=http-whereami-lb
gcloud compute forwarding-rules create http-content-rule \
    --load-balancing-scheme=EXTERNAL_MANAGED \
    --global \
    --target-http-proxy=http-whereami-lb  \
    --ports=80


# Changing 90 10 into 80 20?

If you need so, you need to "gcloud UrlMap update".
No HTTP proxy or fwd rule recreation, all good. just that.
