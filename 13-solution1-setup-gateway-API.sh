#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
#set -x
set -e

# TODO: array of 2 or maybe even better bash hash: https://stackoverflow.com/questions/1494178/how-to-define-hash-tables-in-bash
DEFAULT_APP="app01"                       # app01 / app02
DEFAULT_APP_SELECTOR="app01-kupython"     # app01-kupython / app02-kuruby
DEFAULT_APP_IMAGE="skaf-app01-python-buildpacks"   # skaf-app01-python-buildpacks // ricc-app02-kuruby-skaffold

APP_NAME="${1:-$DEFAULT_APP}"
K8S_APP_SELECTOR="${2:-$DEFAULT_APP_SELECTOR}"
K8S_APP_IMAGE="${3:-DEFAULT_APP_IMAGE}" # "skaf-app01-python-buildpacks"
# Add your code here:

#kubectl config get-contexts | grep cicd | grep "$PROJECT_ID" | grep "$REGION"

#kubectl apply --context "$GKE_CANARY_CLUSTER_CONTEXT"
white "Usage (as I want it): $0 <APPNAME> <..>"
red Dear friends and colleagues this is STILL WIP. Ricc is implementing this for App01/02 since the POC works for a generic STORE.
yellow Try to use app01 with solution01 and make it parametric in ARGV..
white "Now I proceed to apply solution 1 for: $APP_NAME. If wrong, call me with proper usage."

#4.  enable gateway apis
kubectl --context="$GKE_CANARY_CLUSTER_CONTEXT" apply -k "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.4.3"
kubectl --context="$GKE_PROD_CLUSTER_CONTEXT"   apply -k "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.4.3"

################################################################################
# Now we do our k8s manifests. Since we're multi-app we need to do some manual plumbing on the manifests
# I'll use sed, but hopefully I'll kustomize it later.
################################################################################

# ensure out dir exists..
mkdir -p "$GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/out/"

white This grep output should be null:
egrep "store|v2" $GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/templates/[a-z]*yaml | egrep -v '^#'

###############################################
# set up additional variables for the for cycle
REGION="${GCLOUD_REGION}"
SHORT_REGION="$(_shorten_region "$REGION")"
PREFIX="${APP_NAME}-${SHORT_REGION}" # maybe in the future PREFIX = APP-REGION

###############################################
SOLUTION1_TEMPLATING_VER="1.1"
# 1.1 14jul22 Added support for short regions which def acto changed the naming convention!
# 1.0 13jul22 Initial stesure.
###############################################

for TEMPLATE_FILE in "$GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/templates/"*.template.yaml ; do
  DEST_FILE=$(echo "$TEMPLATE_FILE" | sed s:/templates/:/out/:)
  echo "Hydrating template '$TEMPLATE_FILE' [v.$SOLUTION1_TEMPLATING_VER] into this tmp out/ file: $DEST_FILE:"
  (
    echo '###########################################################'
    echo "# Created by $0 v$SOLUTION1_TEMPLATING_VER on `date` on `hostname`"
    echo "# Edit at your own risk as it'll be soon overwritten. Maybe."
    echo '###########################################################'
    cat "$TEMPLATE_FILE"  | egrep -v '^#'  # remove comments
  )|
    sed -e "s/__MY_PROJECT_ID__/$PROJECT_ID/g" |
    sed -e "s/__PREFIX__/$PREFIX/g" |
    sed -e "s/__APP_NAME__/$APP_NAME/g" |
    sed -e "s/__APPNAME__/$APP_NAME/g" |    # I know what you thinking..
    sed -e "s/__K8S_APP_SELECTOR__/$K8S_APP_SELECTOR/g" |    # I know what you thinking..
    sed -e "s/__MY_REGION__/$REGION/g" |
    sed -e "s/__MY_DOMAIN__/$MY_DOMAIN/g" |
    #sed -e "s/__MY_VERSION_/$CLOUD_DEPLOY_TEMPLATING_VER/g" |
    #egrep 'cluster|VER' |
      tee "$DEST_FILE" >/dev/null
done
green Done.

yellow Now we can issue a kubectl on the out dir..
echo "TODO:  kubectl apply -f $GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/out/"

kubectl --context="$GKE_CANARY_CLUSTER_CONTEXT" apply -f "$GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/out/"

#######################
# End of your code here
#######################
_allgood_post_script
echo Everything is ok.
