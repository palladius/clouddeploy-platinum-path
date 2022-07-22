#!/bin/bash


SCRIPT_VERSION="0.10c"
## HISTORY
# 2022-07-22 0.11 Let's say the first CB2 tagging works :)
# 2022-07-22 0.10 Starting working with auto-tagging. Cautiously
# 2022-06-10 0.9  Still doesnt work.

# This will be called
ARGV_DEPLOY_UNIT="$1"               # eg 'app02'
ARGV_DEPLOY_REGION="$2"             # eg 'europe-west1' deploy region
ARGV_DATETIME="$3"      # it is the short _ARTIFACT_REPONAME, eg ARTIFACT_REPONAME=cicd-plat
ARGV_DATETIME2="$4"

export ARTIFACT_REPONAME="$3"
export REGION="$2"
export SKAFFOLD_DEFAULT_REPO="${REGION}-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REPONAME"
export ARTIFACT_LONG_REPO_PATH="$SKAFFOLD_DEFAULT_REPO"
export APPXX="$1"

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
echo "ARGV3:            $3" # 3.
echo "ARGV4:            $4" # 4. TBD
echo "FOO:              $FOO"
echo "CBENV_BUILD_ID:   $CBENV_BUILD_ID"
echo "PROJECT_ID:       $PROJECT_ID"
echo "PROJECT_NUMBER:   $PROJECT_NUMBER"
echo "REV:              $REV"

echo "== CBv2 vars =="
echo "SKAFFOLD_DEFAULT_REPO: '$SKAFFOLD_DEFAULT_REPO'"
echo "ARTIFACT_REPONAME: $ARTIFACT_REPONAME"
echo "REGION: $REGION"
echo "SKAFFOLD_DEFAULT_REPO: $SKAFFOLD_DEFAULT_REPO"
echo "ARTIFACT_LONG_REPO_PATH: $ARTIFACT_LONG_REPO_PATH"
echo "APPXX: $APPXX"

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
export DOCKER_IMAGE_VERSION="v${SUPERDUPER_MAGIC_VERSION}"

echo "1 _ARTIFACT_REPONAME=$_ARTIFACT_REPONAME"
echo "2  ARTIFACT_REPONAME=$ARTIFACT_REPONAME"
# gcloud artifacts docker images list "$ARTIFACT_LONG_REPO_PATH" ||
#   echo Some error maybe ARTIFACT_LONG_REPO_PATH/SKAFFOLD_DEFAULT_REPO unknown. But skaffold has it so should be inferrable from image..

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

# Step 1 done. I just need to get the `ricc-app02-kuruby-skaffold` part. I hate the day i made this different from app name :)
#
# $ gcloud artifacts docker tags list $ARTIFACT_LONG_REPO_PATH/ricc-app02-kuruby-skaffold  --limit 1 --format yaml
# Listing items under project cicd-platinum-test001, location europe-west1, repository cicd-plat.

# ---
# image: europe-west1-docker.pkg.dev/cicd-platinum-test001/cicd-plat/ricc-app02-kuruby-skaffold
# tag: projects/cicd-platinum-test001/locations/europe-west1/repositories/cicd-plat/packages/ricc-app02-kuruby-skaffold/tags/2893429
# version: projects/cicd-platinum-test001/locations/europe-west1/repositories/cicd-plat/packages/ricc-app02-kuruby-skaffold/versions/sha256:4b1fe68c55c25763d4a2617db4a5d9939bc6e61c5e7130a8268b2ba913061dd7
LATEST_TAG_FOR_MY_APP=$(gcloud artifacts docker tags list $ARTIFACT_LONG_REPO_PATH/   --format yaml | grep "$APPXX" | egrep "^tag:" | head -1 |  cut -f 2 -d' '  ) # | cut -f 10 -d'/'
# Smart! Since i dont know here the name of the image but I know it GREPS app0X I'll use this information:
# $ gcloud artifacts docker tags list $ARTIFACT_LONG_REPO_PATH/   --format yaml | grep app01 | grep tag | head
# Listing items under project cicd-platinum-test001, location europe-west1, repository cicd-plat.
# tag: projects/cicd-platinum-test001/locations/europe-west1/repositories/cicd-plat/packages/skaf-app01-python-buildpacks/tags/2893429
# tag: projects/cicd-platinum-test001/locations/europe-west1/repositories/cicd-plat/packages/skaf-app01-python-buildpacks/tags/2bd4353
# tag: projects/cicd-platinum-test001/locations/europe-west1/repositories/cicd-plat/packages/skaf-app01-python-buildpacks/tags/3b451cd
# tag: projects/cicd-platinum-test001/locations/europe-west1/repositories/cicd-plat/packages/skaf-app01-python-buildpacks/tags/50c9d16
# tag: projects/cicd-platinum-test001/locations/europe-west1/repositories/cicd-plat/packages/skaf-app01-python-buildpacks/tags/ea60714

# No it doesnt work i need both the TAG and the IMAGE so I need to grep both and make an EXACT query in yaml. Look at this how amazing

# gcloud artifacts docker tags list $ARTIFACT_LONG_REPO_PATH/   --format yaml --filter image~app02 --limit 1
# Listing items under project cicd-platinum-test001, location europe-west1, repository cicd-plat.

# ---
# image: europe-west1-docker.pkg.dev/cicd-platinum-test001/cicd-plat/ricc-app02-kuruby-skaffold
# tag: projects/cicd-platinum-test001/locations/europe-west1/repositories/cicd-plat/packages/ricc-app02-kuruby-skaffold/tags/2893429
# version: projects/cicd-platinum-test001/locations/europe-west1/repositories/cicd-plat/packages/ricc-app02-kuruby-skaffold/versions/sha256:4b1fe68c55c25763d4a2617db4a5d9939bc6e61c5e7130a8268b2ba913061dd7

gcloud artifacts docker tags list $ARTIFACT_LONG_REPO_PATH/  --format yaml --filter image~"$APPXX" --limit 1

function _latest_image_yaml() {
  gcloud artifacts docker tags list $ARTIFACT_LONG_REPO_PATH/  --format yaml --filter image~"$APPXX" --limit 1
}

LATEST_IMAGE_YAML="$(_latest_image_yaml)"
LATEST_IMAGE=$(_latest_image_yaml | egrep "^image: " | cut -f 2 -d' ') # eg, "europe-west1-docker.pkg.dev/cicd-platinum-test001/cicd-plat/ricc-app02-kuruby-skaffold"
LATEST_TAG=$(_latest_image_yaml | egrep "^tag: " | cut -f 2 -d' ' | cut -f 10 -d/ )   # eg, "projects/cicd-platinum-test001/locations/europe-west1/repositories/cicd-plat/packages/ricc-app02-kuruby-skaffold/tags/2893429" => 2893429
# This will fail for python :/
#BUGGED_TAG=$(gcloud artifacts docker tags list "$ARTIFACT_LONG_REPO_PATH/ricc-app02-kuruby-skaffold"  --limit 1 --format yaml | egrep "^tag:" |  cut -f 2 -d' ' | cut -f 10 -d/)
#echo "BUGGED_TAG: $BUGGED_TAG"

COMMAND_TO_TAG_IS_NOW="gcloud artifacts docker tags add $LATEST_IMAGE:$LATEST_TAG $LATEST_IMAGE:latest-cb2"

####################
# LATEST echoes
echo "COMMAND_TO_TAG_IS_NOW: $COMMAND_TO_TAG_IS_NOW"
echo "LATEST_IMAGE_YAML: $LATEST_IMAGE_YAML"
echo "SUPERDUPER_MAGIC_VERSION: $SUPERDUPER_MAGIC_VERSION"
echo "DOCKER_IMAGE_VERSION: $DOCKER_IMAGE_VERSION"

gcloud artifacts docker tags add "$LATEST_IMAGE:$LATEST_TAG" "$LATEST_IMAGE:latest-cb2"
gcloud artifacts docker tags add "$LATEST_IMAGE:$LATEST_TAG" "$LATEST_IMAGE:$DOCKER_IMAGE_VERSION"
gcloud artifacts docker tags add "$LATEST_IMAGE:$LATEST_TAG" "$LATEST_IMAGE:v${SUPERDUPER_MAGIC_VERSION}"



echo Build ended correctly.
