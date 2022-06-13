#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
set -x
set -e

# Add your code here:
gcloud iam service-accounts create terraform-cld-deploy-setup --display-name="SvcAcct to set up Cloud Deploy"







# End of your code here
verde Tutto ok.
