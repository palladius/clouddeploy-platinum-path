#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal "Config doesnt exist please create .env.sh"
set -x
set -e

# Add your code here:
#export SKAFFOLD_BUCKET="${PROJECT_ID}-skaffoldcache"
echo "We're now creating a bucket to land Skaffold cache for our apps."

proceed_if_error_matches "A Cloud Storage bucket named '$SKAFFOLD_BUCKET' already exists" \
  gsutil mb "gs://$SKAFFOLD_BUCKET"

# TODO security maniacs - make sure it doesnt exist, could be a rm -f before? But then it could fail...
touch /tmp/EmptyFile

ls apps/| grep -v README | while read MODULE ; do
  #TODO Skip if not DIR test -d $MODULE
  gsutil cp /tmp/EmptyFile gs://$SKAFFOLD_BUCKET/skaffold-cache/$MODULE.txt
done

# End of your code here
echo Everything is ok.