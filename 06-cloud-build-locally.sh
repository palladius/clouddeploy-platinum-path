#!/bin/bash

MODULE_TO_BUILD="${1:-frontend}"
COLOR=${2:-orange}

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
set -x
set -e

# Add your code here:
cloud-build-local --config="cloudbuild.yaml" --dryrun=false \
  --substitutions "_DEPLOY_UNIT=$MODULE_TO_BUILD,_REGION=$REGION" \
  --push boa-cicd/









# End of your code here
verde Tutto ok.
