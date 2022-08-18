#!/bin/bash

set -e

# Defined also in .env.sh.post BUT I need to define it here for the first time :)
function _fatal() {
    echo "$*" >&1
    exit 42
}

source '.env.sh' || _fatal "Config doesnt exist please create .env.sh"

gcloud config configurations create $GCLOUD_CONFIG ||
  gcloud config configurations activate $GCLOUD_CONFIG ||
    gcloud config configurations create $GCLOUD_CONFIG
gcloud config set account $ACCOUNT
gcloud config set project $PROJECT_ID
PROJECT_ID=$(gcloud config get-value project)

# Enable APIs...
gcloud services enable \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  clouddeploy.googleapis.com \
  compute.googleapis.com \
  container.googleapis.com \
  sourcerepo.googleapis.com \
    gkehub.googleapis.com \
    multiclusterservicediscovery.googleapis.com \
    multiclusteringress.googleapis.com \
    trafficdirector.googleapis.com
    # last 4 are for ILB setup.

# Set defaults..
gcloud config set run/region "$REGION"
gcloud config set deploy/region "$CLOUD_DEPLOY_REGION"
#gcloud config set build/region "$REGION" # This would be bad since global build has more Quota ;)
gcloud config set compute/region  "$GCLOUD_REGION"
#https://cloud.google.com/sdk/gcloud/reference/config/set
#gcloud config set container/cluster "cicd-dev"

# In Italy we say "The eye wants its part too". If you like colors, use this :)
# which lolcat || gem install lolcat
# gcloud config list | lolcat
gcloud config list
################################################
# If you need to aunthenticate your app
################################################
# This is needed when you want to use Python, Node, .. APIs and you cant / dont
# want to use a service account.
#
#   $ gcloud auth application-default login
#
# Once I got a mysterious error which asked me to RE-authorize:
#
#   $ gcloud auth login --update-adc
#
# Note this is Riccardo being lazy. Proper way is
# to set up a Service Account with proper access
# to just the resourees you need. This might come
# in a next iteration.
################################################

# Needed on a new computer. Smartly installs if needed.
which skaffold >/dev/null && echo skaffold exists. All good. ||
  gcloud components install skaffold

touch ".$APPNAME.appname"

# sets `kubetcl`` context to this cluster, I'll do DEV CANARY PROD but keep DEV
# LAST so it will stick so do NOT change the order :)

# for ITER_CLUSTER in cicd-canary cicd-prod cicd-dev ; do
#   # Muting STDERR since we don't really care. Will fail. Or maybe we should move to AFTER GKE
#   gcloud container clusters get-credentials "$ITER_CLUSTER" --region "$GKE_REGION" 2>/dev/null ||
#       yellow "This will fail before you run step 01... so no biggie if this fails."
# done

# TODO(ricc): check ENV_SH_CONFIG from sourced to the .dist and suggest to check the HISTORY
#             for missing VARs.

echo Make sure your bash is AT LEAST v4 or more:
bash --version | egrep 'GNU bash' | lolcat # | cut -f 4 -d' ' | lolcat

# Feel free to add this PS1 to your bashrc :)
#export PS1="\[\e]0;${PROJECT_ID:-MissingProject}\a\]\u@\h:\[\033[1;34m\]\w$([[ -n $PROJECT_ID ]] && printf " \[\033[1;33m\](%s)" "${PROJECT_ID}" )\[\033[00m\]$ \[\033k\033\\"

# End of your code here
_allgood_post_script
echo Everything is ok.
