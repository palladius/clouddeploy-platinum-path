#!/bin/bash

APPXX="${1:-app01}"

set -e

kustomize build $APPXX/k8s/overlays/dev/         > tmp/$APPXX-tmp-dev.yaml
kustomize build $APPXX/k8s/overlays/staging/     > tmp/$APPXX-tmp-staging.yaml
kustomize build $APPXX/k8s/overlays/canary/      > tmp/$APPXX-tmp-canary.yaml
kustomize build $APPXX/k8s/overlays/production/  > tmp/$APPXX-tmp-production.yaml

diff tmp/$APPXX-tmp-production.yaml tmp/$APPXX-tmp-canary.yaml | tee tmp/$APPXX-prod-vs-canary.diff >/dev/null

echo "Done $APPXX"
