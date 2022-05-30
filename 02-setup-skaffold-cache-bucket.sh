#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
set -x
set -e

# Add your code here:
#export SKAFFOLD_BUCKET="${PROJECT_ID}-skaffoldcache"
echo Were now creating a bucket to land Skaffold cache for our apps.

echo gsutil mb "gs://$SKAFFOLD_BUCKET"

touch /tmp/EmptyFile

ls apps/| grep -v README | while read MODULE ; do
  #TODO Skip if not DIR test -d $MODULE
  gsutil cp /tmp/EmptyFile gs://$SKAFFOLD_BUCKET/skaffold-cache/$MODULE.txt
done

# Note this export wont work..
export SKAFFOLD_DEFAULT_REPO="${REGION}-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REPONAME"
echodo skaffold config set default-repo "$SKAFFOLD_DEFAULT_REPO"

# End of your code here
verde Tutto ok.
