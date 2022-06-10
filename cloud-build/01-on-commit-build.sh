#!/bin/bash

# This will be called


#  | tr '[:upper:]' '[:lower:]' 
export APPROXIMATE_MAGIC_VERSION=$(cat VERSION  | tr '[:upper:]' '[:lower:]' )
export SUPERDUPER_MAGIC_VERSION=$(cat "apps/$ARGV_DEPLOY_UNIT/VERSION" )
# need to pass from CLI since it wont expand within bash :/

ARGV_DEPLOY_UNIT="$1"
ARGV_DEPLOY_REGION="$2" # deploy region
ARGV_DATETIME="$3"
ARGV_DATETIME2="$4"

BASH_DATETIME=$(date +%Y%m%d-%H%M)

# These dont work: https://screenshot.googleplex.com/ABKSubdGMi99Xy6
echo "CB_DATE/TIME:     $DATE-$TIME"
echo "BASH_DATETIME:    $BASH_DATETIME"             # Edward: +%y%m%d-%s but i dont like it
echo "APPROXIMATE_MAGIC_VERSION: $APPROXIMATE_MAGIC_VERSION"    # fake version, local to here and not from a certain app
echo "SUPERDUPER_MAGIC_VERSION:  $SUPERDUPER_MAGIC_VERSION" # The REAL thing, scrapes for VERSION number in proper apps/$MYAPP/VERSION :)
echo "ARGV1:            $1" # 1. ARGV_DEPLOY_UNIT, eg 'app02'
echo "ARGV2:            $2" # 2. ARGV_DEPLOY_REGION, eg 'europe-west1'
echo "ARGV3:            $3" # 3. ARGV_DATETIME - useless, eg '$DATE-£TIME' - useless
echo "ARGV4:            $4" # 3. ARGV_DATETIME - useless, eg '$DATE-£TIME' - useless
echo "FOO:              $FOO"
echo "CBENV_BUILD_ID:   $CBENV_BUILD_ID"
echo "PROJECT_ID:       $PROJECT_ID"
echo "PROJECT_NUMBER:   $PROJECT_NUMBER"
echo "REV:              $REV"
# This dont work:
#echo "CBENV_DATETIME1:  $CBENV_DATETIME1"
#echo "CBENV_DATETIME2:  $CBENV_DATETIME2"
#echo "_DEPLOY_UNIT:     $_DEPLOY_UNIT"
#echo "_DEPLOY_REGION:   $_DEPLOY_REGION"

set -x 

gcloud deploy releases create "a$ARGV_DEPLOY_UNIT-b$BASH_DATETIME-c$SUPERDUPER_MAGIC_VERSION" \
        --delivery-pipeline="$ARGV_DEPLOY_UNIT" \
        --build-artifacts=/workspace/artifacts.json \
        --skaffold-file="apps/$ARGV_DEPLOY_UNIT/skaffold.yaml" \
        --region="${ARGV_DEPLOY_REGION}"

echo All done.