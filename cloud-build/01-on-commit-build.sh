#!/bin/bash

# This will be called


#  | tr '[:upper:]' '[:lower:]' 
export MAGIC_VERSION=$(cat VERSION  | tr '[:upper:]' '[:lower:]' )
# need to pass from CLI since it wont expand within bash :/
export CLOUDBUILD_DATETIME="$1"

ARGV_DEPLOY_UNIT="$1"
ARGV_REGION="$2"
ARGV_DATETIME="$3"

echo "_DEPLOY_UNIT:     $_DEPLOY_UNIT"
echo "_DEPLOY_REGION:   $_DEPLOY_REGION"
echo "CB_DATETIME1:      $$DATE-$$TIME"
echo "CB_DATETIME2:      $CLOUDBUILD_DATETIME"
echo "EdwardDATEIME:    $(date +%y%m%d-%s)"
echo "MagicVersion:     $MAGIC_VERSION"
echo "SuperMagicVersion: $(cat apps/$_DEPLOY_UNIT/VERSION )"
echo "ARGV1:            $1"
echo "ARGV2:            $2"
echo "ARGV3:            $3"
echo "FOO:              $FOO"
echo "CBENV_BUILD_ID:   $CBENV_BUILD_ID"
echo "PROJECT_ID:       $PROJECT_ID"
echo "PROJECT_NUMBER:   $PROJECT_NUMBER"
echo "REV:              $REV"
echo "CBENV_DATETIME1:  $CBENV_DATETIME1"
echo "CBENV_DATETIME2:  $CBENV_DATETIME2"

set -x 

gcloud deploy releases create "$_DEPLOY_UNIT-$CBENV_DATETIME-$MAGIC_VERSION" \
        --delivery-pipeline="$_DEPLOY_UNIT" \
        --build-artifacts=/workspace/artifacts.json \
        --skaffold-file="apps/$_DEPLOY_UNIT/skaffold.yaml" \
        --region="${_DEPLOY_REGION}"

echo All done.