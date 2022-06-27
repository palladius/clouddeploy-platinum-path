#!/bin/bash

#################################
# To invoke this script from LOCAL to see if everything is set up correctly, try this:
#
# $ FAKEIT=true ./cloud-build/01-on-commit-build.sh blah blah blah..
#
# or simply (DRY):
#
# $ make fake-build-shell-script
#
#################################

SCRIPT_VERSION="1.0d"
## HISTORY
# 2022-06-10 1.0  Finally it works since 1.0d version!
# 2022-06-10 0.9  Still doesnt work.

# This will be called
ARGV_DEPLOY_UNIT="$1"
ARGV_DEPLOY_REGION="$2" # deploy region
ARGV_DATETIME="$3"
ARGV_DATETIME2="$4"

# Fixing this error:
# ERROR: (gcloud.deploy.releases.create) INVALID_ARGUMENT: resource ids must be lower-case letters, numbers, and hyphens, with the first character a letter, the last a letter or a number, and a 63 character maximum
function cleanup_for_cloudbuild() {
  tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9-]/-/g'
}

export SUPERDUPER_MAGIC_VERSION=$(cat "apps/$ARGV_DEPLOY_UNIT/VERSION" | cleanup_for_cloudbuild )
# need to pass from CLI since it wont expand within bash :/

BASH_DATETIME=$(date +%Y%m%d-%H%M)


echo "== Welcome to $0 v$SCRIPT_VERSION =="
echo "We've been deploying stuff since 2022!"

# These dont work: https://screenshot.googleplex.com/ABKSubdGMi99Xy6
echo "CB_DATE/TIME:     $DATE-$TIME"
echo "BASH_DATETIME:    $BASH_DATETIME"             # Edward: +%y%m%d-%s but i dont like it
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
#TODO when everything work put this and remove &&: set -e

if [ "true" = "$FAKEIT" ]; then
        echo Faking it since probably you called me from CLI to troubleshoot me 
        GCLOUD="echo [FAKING] GcLoUd"
else 
        GCLOUD="gcloud"
fi

RELEASE_NAME="$ARGV_DEPLOY_UNIT-$BASH_DATETIME-v$SUPERDUPER_MAGIC_VERSION"
$GCLOUD deploy releases create "$RELEASE_NAME"  \
        --delivery-pipeline="$ARGV_DEPLOY_UNIT" \
        --build-artifacts=/workspace/artifacts.json \
        --skaffold-file="apps/$ARGV_DEPLOY_UNIT/skaffold.yaml" \
        --region="${ARGV_DEPLOY_REGION}" && 
        echo "$RELEASE_NAME" > "$RELEASE_FILE_PATH" # /workspace/.cb.releasename
echo All done.