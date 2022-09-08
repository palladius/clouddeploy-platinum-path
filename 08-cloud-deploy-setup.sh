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


# Created with codelabba.rb v.1.4a
source .env.sh || fatal "Config doesnt exist please create .env.sh"
set -x
set -e

# function delete_old_pipelines() {
#   echo This is just as a memento for future cleanup:
#   gcloud deploy delivery-pipelines delete app01-python-v1-0alpha
#   gcloud deploy delivery-pipelines delete app01-python
#   gcloud deploy delivery-pipelines delete app02-ruby
# }

# Add your code here:

CLOUD_DEPLOY_TEMPLATING_VER="1-2"

cat clouddeploy.template.yaml |
  sed -e "s/MY_PROJECT_ID/$PROJECT_ID/g" |
  sed -e "s/MY_REGION/$REGION/g" |
  sed -e "s/_MY_VERSION_/$CLOUD_DEPLOY_TEMPLATING_VER/g" |
  tee .tmp.clouddeploy.yaml |
  egrep 'cluster|VER'

# In Zurich doesnt work, :( euw6
gcloud --project $PROJECT_ID deploy apply --file .tmp.clouddeploy.yaml --region "$CLOUD_DEPLOY_REGION"



# End of your code here
_allgood_post_script
echo Everything is ok.
