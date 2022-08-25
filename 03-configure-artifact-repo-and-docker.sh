#!/bin/bash
function _fatal() {
    echo "$*" >&2
    exit 42
}
# Created with codelabba.rb v.1.4a
source .env.sh || _fatal "Config doesnt exist please create .env.sh"
set -x
set -e

# Add your code here:
gcloud container clusters get-credentials cicd-dev --region $REGION --project $PROJECT_ID

# goes in 03 script..
#gcloud auth configure-docker $REGION-docker.pkg.dev

# Skaffold auto-config
#PLEONASTIC: skaffold config set default-repo "$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REPONAME"
yellow skaffold config set default-repo "$REGION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REPONAME"
yellow skaffold config set default-repo "$SKAFFOLD_DEFAULT_REPO"

# End of your code here
_allgood_post_script
echo Everything is ok.
