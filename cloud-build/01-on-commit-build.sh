#!/bin/bash

# This will be called


#  | tr '[:upper:]' '[:lower:]' 
export MAGIC_VERSION=$(cat VERSION  | tr '[:upper:]' '[:lower:]' )
# need to pass from CLI since it wont expand within bash :/
export CLOUDBUILD_DATETIME="$1"

ARGV_DEPLOY_UNIT="$1"
ARGV_DEPLOY_REGION="$2" # deploy region
ARGV_DATETIME="$3"

# These dont work: https://screenshot.googleplex.com/ABKSubdGMi99Xy6
#echo "_DEPLOY_UNIT:     $_DEPLOY_UNIT"
#echo "_DEPLOY_REGION:   $_DEPLOY_REGION"
echo "CB_DATETIME1:     $$DATE-$$TIME"
echo "CB_DATETIME2:     $CLOUDBUILD_DATETIME"
echo "BASH_DATETIME:    $(date +%y%m%d-%s)"             # from Edward
echo "MAGIC_VERSION:    $MAGIC_VERSION"
echo "SuperMagicVersion: $(cat apps/$ARGV_DEPLOY_UNIT/VERSION )" # The REAL thing
echo "ARGV1:            $1" # 1. ARGV_DEPLOY_UNIT, eg 'app02'
echo "ARGV2:            $2" # 2. ARGV_DEPLOY_REGION, eg 'europe-west1'
echo "ARGV3:            $3" # 3. ARGV_DATETIME - useless, eg '$DATE-£TIME' - useless
echo "FOO:              $FOO"
echo "CBENV_BUILD_ID:   $CBENV_BUILD_ID"
echo "PROJECT_ID:       $PROJECT_ID"
echo "PROJECT_NUMBER:   $PROJECT_NUMBER"
echo "REV:              $REV"
echo "CBENV_DATETIME1:  $CBENV_DATETIME1"
echo "CBENV_DATETIME2:  $CBENV_DATETIME2"

set -x 

gcloud deploy releases create "$ARGV_DEPLOY_UNIT-$BASH_DATETIME-$SuperMagicVersion" \
        --delivery-pipeline="$ARGV_DEPLOY_UNIT" \
        --build-artifacts=/workspace/artifacts.json \
        --skaffold-file="apps/$ARGV_DEPLOY_UNIT/skaffold.yaml" \
        --region="${ARGV_DEPLOY_REGION}"

echo All done.