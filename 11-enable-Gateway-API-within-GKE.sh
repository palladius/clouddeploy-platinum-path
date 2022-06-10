#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
set -x
set -e

# Add your code here:
kubectl apply -k "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.4.3"
kubectl get gatewayclass

# CREO IN europe-west6
gcloud compute networks subnets create dmarzi-proxy \
    --purpose=REGIONAL_MANAGED_PROXY \
    --role=ACTIVE \
    --region="$GCLOUD_REGION" \
    --network='default' \
    --range='192.168.0.0/24'

# bingo! https://screenshot.googleplex.com/h5ZXAUgy5wWrvqh

# End of your code here
echo YAY. Tutto ok.
