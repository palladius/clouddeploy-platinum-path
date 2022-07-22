#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal "Config doesnt exist please create .env.sh"
#set -x
set -e

# Add your code here:
PIPELINE="${1:-app01}"
INITIAL_STAGE="${2:-dev}"    # seems useless, probably cos I just deploy a release which is independent on which stage it is. Good to learn :)
DESIRED_STAGE="${3:-staging}"

yellow "Usage: $0 [appXX] [STAGE_FROM] [STAGE_TO] (STAGES can be: dev, staging, canary, production)"
# COPIED FROM 09... IF FAST ENOUGH i COULD actually move to .env.sh
LATEST_SUCCESSFUL_RELEASE="$(get_latest_successful_release_by_pipeline "$PIPELINE" )"

if [ -z "$LATEST_SUCCESSFUL_RELEASE" ]; then
    _error "Sorry, no release found. Probably you need to build something to dev/canary first. Have you committed code to $PIPELINE yet? Let me show you what I see:"
    gcloud deploy releases list --delivery-pipeline="$PIPELINE" --format 'table(renderState,name)'
    exit 153
fi
green "Now promoting DEV to STAG for PIPELINE=$PIPELINE (from ARGV1) and RELEASE=$LATEST_SUCCESSFUL_RELEASE.."
set -x
gcloud deploy releases promote --to-target "$DESIRED_STAGE" --region "$CLOUD_DEPLOY_REGION" \
    --release "$LATEST_SUCCESSFUL_RELEASE" --delivery-pipeline="$PIPELINE" --quiet



# End of your code here
_allgood_post_script
echo Everything is ok.
