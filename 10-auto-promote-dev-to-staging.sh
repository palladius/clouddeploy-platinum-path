#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
#set -x
set -e

# Add your code here:
PIPELINE="${1:-app01}"

# COPIED FROM 09... IF FAST ENOUGH i COULD actually move to .env.sh
LATEST_SUCCESSFUL_RELEASE=$(get_latest_successful_release_by_pipeline "$PIPELINE" )

green "Now promoting DEV to STAG for PIPELINE=$PIPELINE (from ARGV1) and RELEASE=$LATEST_SUCCESSFUL_RELEASE.."
gcloud deploy releases promote --to-target staging --region "$CLOUD_DEPLOY_REGION" \
    --release "$LATEST_SUCCESSFUL_RELEASE" --delivery-pipeline=$PIPELINE --quiet





# End of your code here
verde Tutto ok.
