#!/bin/bash

# This will be called

echo "_DEPLOY_UNIT:     $_DEPLOY_UNIT"
echo "_DEPLOY_REGION:   $_DEPLOY_REGION"
echo "CB_DATETIME:      $$DATE-$$TIME"
echo "EdwardDATEIME:    $(date +%y%m%d-%s)"

gcloud deploy releases
        create "$_DEPLOY_UNIT-$$DATE-$$TIME-$(cat VERSION)" 
        --delivery-pipeline="$_DEPLOY_UNIT"
        --build-artifacts=/workspace/artifacts.json
        --skaffold-file="apps/$_DEPLOY_UNIT"/skaffold.yaml"
        --region="${_DEPLOY_REGION}"