#!/bin/bash


SCRIPT_VERSION="0.10b"
## HISTORY
# 2022-07-22 0.10 Starting working with auto-tagging. Cautiously
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
set -e

# TODO
# once
cd /workspace/apps/$ARGV_DEPLOY_UNIT

# Ensure the test passes. TODO(ricc): move to skaffrold testing capabilities.
make test

echo 3. So far so good. Now approve from dev to STAGING. But I need the release name... is it...
# When this will work I'll need to create an app to applaude me and link thru go/applaude-ricc.

echo "4. RELEASE_FILE=$RELEASE_FILE_PATH"
RELEASE_NAME=$(cat "$RELEASE_FILE_PATH")
echo "5. RELEASE_NAME=$RELEASE_NAME"
# /workspace/.cb.releasename

# 6. do something with this... like
DESIRED_STAGE="staging"
CLOUD_DEPLOY_REGION="$ARGV_DEPLOY_REGION"
LATEST_SUCCESSFUL_RELEASE="$RELEASE_NAME"
PIPELINE="$ARGV_DEPLOY_UNIT"
gcloud deploy releases promote --to-target "$DESIRED_STAGE" --region "$CLOUD_DEPLOY_REGION" \
    --release "$LATEST_SUCCESSFUL_RELEASE" --delivery-pipeline=$PIPELINE --quiet

# 7 TODO Ricc, create a TAG with "v$VERSION" and push the tag for AR to pick it up.
# possibly also symlink it to `LATEST`` or better `LATEST-STAGING` (because we have
# four latest).
echo "Step 07. Magic tagging now.."
function cleanup_for_cloudbuild() {
  tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9-]/-/g'
}
# This is script version, like apps/app01/VERSION => "2.1blah"
export SUPERDUPER_MAGIC_VERSION=$(cat "apps/$ARGV_DEPLOY_UNIT/VERSION" | cleanup_for_cloudbuild )
# This wil make a "2.1BLAh" into a "2-1blah"
# Adding a 'v' for better semantics
export DOCKER_IMAGE_VERSION="v$SUPERDUPER_MAGIC_VERSION"

echo "1 _ARTIFACT_REPONAME=$_ARTIFACT_REPONAME"
echo "2  ARTIFACT_REPONAME=$ARTIFACT_REPONAME"
gcloud artifacts docker images list "$ARTIFACT_LONG_REPO_PATH" ||
  echo Some error maybe ARTIFACT_LONG_REPO_PATH/SKAFFOLD_DEFAULT_REPO unknown. But skaffold has it so should be inferrable from image..

#$ gcloud artifacts docker tags list $ARTIFACT_LONG_REPO_PATH/ricc-app02-kuruby-skaffold
# Listing items under project cicd-platinum-test001, location europe-west1, repository cicd-plat.

# TAG       IMAGE                                                                                   DIGEST
# 50c9d16   europe-west1-docker.pkg.dev/cicd-platinum-test001/cicd-plat/ricc-app02-kuruby-skaffold  sha256:00b5cdfe12283126f96838dbdc3dae409f20837a516c6a50d0febc12b1ab777e
# ea60714   europe-west1-docker.pkg.dev/cicd-platinum-test001/cicd-plat/ricc-app02-kuruby-skaffold  sha256:00b5cdfe12283126f96838dbdc3dae409f20837a516c6a50d0febc12b1ab777e
# manhouse  europe-west1-docker.pkg.dev/cicd-platinum-test001/cicd-plat/ricc-app02-kuruby-skaffold  sha256:00b5cdfe12283126f96838dbdc3dae409f20837a516c6a50d0febc12b1ab777e

# THSI WORKS! Now I just need to automate it!!!
# <watch in awe>
# $ gcloud artifacts docker tags add europe-west1-docker.pkg.dev/cicd-platinum-test001/cicd-plat/ricc-app02-kuruby-skaffold:50c9d16 europe-west1-docker.pkg.dev/cicd-platinum-test001/cicd-plat/ricc-app02-kuruby-skaffold:ricc-gcloud
# </watch in awe>
echo "Riccardo You need to automate sth like this now: gcloud artifacts docker tags add europe-west1-docker.pkg.dev/cicd-platinum-test001/cicd-plat/ricc-app02-kuruby-skaffold:50c9d16 europe-west1-docker.pkg.dev/cicd-platinum-test001/cicd-plat/ricc-app02-kuruby-skaffold:ricc-gcloud"
echo "and to make it work you need to parametrize (1) the big long path, then (2) 50c9d16 (easy grep) and thats it. to do 2 you first need 1."

echo Build ended correctly.
