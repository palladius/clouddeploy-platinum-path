#!/bin/bash
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


MODULE_TO_BUILD="${1:-app01}"
COLOR=${2:-orange}

# Created with codelabba.rb v.1.4a
source .env.sh || fatal "Config doesnt exist please create .env.sh"
set -x
set -e

# Install cloud-build-local if we don't have it yet
which cloud-build-local >/dev/null  &&
  echo cloud-build-local exists. All good. ||
    gcloud components install cloud-build-local

white "Skaffold should be confgured automatically: SKAFFOLD_DEFAULT_REPO=$SKAFFOLD_DEFAULT_REPO"
# Add your code here:
# docs for substitutions: https://cloud.google.com/build/docs/configuring-builds/substitute-variable-values
#  --substitutions "_DEPLOY_UNIT=$MODULE_TO_BUILD,_REGION=$REGION,_ARTIFACT_REPONAME=$ARTIFACT_REPONAME,_DEPLOY_REGION=$CLOUD_DEPLOY_REGION,_APP_VERSION=$PARTICULAR_VERSION_FOR_MODULE" \

PARTICULAR_VERSION_FOR_MODULE=$(cat apps/$MODULE_TO_BUILD/VERSION )

gcloud auth configure-docker $REGION-docker.pkg.dev
# documented herE: https://cloud.google.com/artifact-registry/docs/docker/pushing-and-pulling#auth
#which docker-credential-gcloud  && docker-credential-gcloud configure-docker #  $REGION-docker.pkg.dev

cloud-build-local --config="cloudbuild.yaml" --dryrun=false \
  --substitutions "_DEPLOY_UNIT=$MODULE_TO_BUILD,_REGION=$REGION,_ARTIFACT_REPONAME=$ARTIFACT_REPONAME,_DEPLOY_REGION=$CLOUD_DEPLOY_REGION" \
  --push "apps/$MODULE_TO_BUILD/"

# End of your code here
_allgood_post_script
echo Everything is ok.
