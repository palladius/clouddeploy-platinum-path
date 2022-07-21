#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal "Config doesnt exist please create .env.sh"
set -x
set -e

function delete_old_pipelines() {
  echo This is just as a memento for future cleanup:
  gcloud deploy delivery-pipelines delete app01-python-v1-0alpha
  gcloud deploy delivery-pipelines delete app01-python
  gcloud deploy delivery-pipelines delete app02-ruby	
}
# Add your code here:

# Add roles to default compute engine service account
PROJECT_NUMBER=$(gcloud projects list --filter="$PROJECT_ID" --format="value(PROJECT_NUMBER)")
GCE_SVC_ACCT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
gcloud projects add-iam-policy-binding --member="serviceAccount:${GCE_SVC_ACCT}" --role "roles/storage.objectCreator" "$PROJECT_ID"
gcloud projects add-iam-policy-binding --member="serviceAccount:${GCE_SVC_ACCT}" --role "roles/container.developer" "$PROJECT_ID"

CLOUD_DEPLOY_TEMPLATING_VER="1-2"

cat clouddeploy.template.yaml |
  sed -e "s/MY_PROJECT_ID/$PROJECT_ID/g" |
  sed -e "s/MY_REGION/$REGION/g" |
  sed -e "s/_MY_VERSION_/$CLOUD_DEPLOY_TEMPLATING_VER/g" |
  tee .tmp.clouddeploy.yaml |
  egrep 'cluster|VER' 

#yellow TODO
# Zurich doesnt work, :( euw6
gcloud --project $PROJECT_ID deploy apply --file .tmp.clouddeploy.yaml --region "$CLOUD_DEPLOY_REGION"



# End of your code here
_allgood_post_script
echo Everything is ok.