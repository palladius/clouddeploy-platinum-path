#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
#set -x
set -e

########################################################################
# RICC00. ARGV -> vars for MultiAppK8sRefactoring
########################################################################
# TODO: array of 2 or maybe even better bash hash: https://stackoverflow.com/questions/1494178/how-to-define-hash-tables-in-bash
DEFAULT_APP="app01"                       # app01 / app02
DEFAULT_APP_SELECTOR="app01-kupython"     # app01-kupython / app02-kuruby
DEFAULT_APP_IMAGE="skaf-app01-python-buildpacks"   # skaf-app01-python-buildpacks // ricc-app02-kuruby-skaffold

APP_NAME="${1:-$DEFAULT_APP}"
#K8S_APP_SELECTOR="${2:-$DEFAULT_APP_SELECTOR}"
#K8S_APP_IMAGE="${3:-$DEFAULT_APP_IMAGE}" # "skaf-app01-python-buildpacks"

K8S_APP_SELECTOR="${AppsInterestingHash["$APP_NAME-SELECTOR"]}"
K8S_APP_IMAGE="${AppsInterestingHash["$APP_NAME-IMAGE"]}"
export URLMAP_NAME="${APP_NAME}-$URLMAP_NAME_MTSUFFIX"        # eg: "app02-BLAHBLAH"
export FWD_RULE="${APP_NAME}-${FWD_RULE_MTSUFFIX}"            # eg: "app02-BLAHBLAH"

########################################################################
# Add your code here:
########################################################################

echo "##############################################"
yellow "WORK IN PROGRESS! huge multi-tennant refactor in progress"
#yellow "TODO(ricc): everything is multi-tennant except the FWD RULE part. Shouls have app01/02 in it.."
#yellow "Deploy the GKE manifests. This needs to happen first as it creates the NEGs which this script depends upon."

echo "APP_NAME:    $APP_NAME"
echo "URLMAP_NAME: $URLMAP_NAME"
echo "FWD_RULE:    $FWD_RULE"
echo "K8S_APP_SELECTOR:    $K8S_APP_SELECTOR (useless in sol1)"
echo "K8S_APP_IMAGE:       $K8S_APP_IMAGE    (useless in sol1)"
echo "GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR:       $GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR"
echo "##############################################"

#exit 47
#kubectl config get-contexts | grep cicd | grep "$PROJECT_ID" | grep "$REGION"

#kubectl apply --context "$GKE_CANARY_CLUSTER_CONTEXT"
white "Usage (as I want it): $0 <APPNAME> <..>"
#red Dear friends and colleagues this is STILL WIP. Ricc is implementing this for App01/02 since the POC works for a generic STORE.
#yellow Try to use app01 with solution01 and make it parametric in ARGV..
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
#SHORT_REGION="$(_shorten_region "$REGION")"
PREFIX="${APP_NAME}-${DEFAULT_SHORT_REGION}" # maybe in the future PREFIX = APP-REGION
export IMAGE_NAME="${K8S_APP_IMAGE}"
###############################################

SOLUTION1_TEMPLATING_VER="1.1"
###############################################
# 1.1 14jul22 Added support for short regions which def acto changed the naming convention!
# 1.0 13jul22 Initial stesure.
###############################################

# MultiAppK8sRefactoring: first script (just ported to obsolete script 2)
make clean
smart_apply_k8s_templates "$GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR"

#yellow Now we can issue a kubectl on the out dir..
#echo "TODO:  kubectl apply -f $GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/out/"

kubectl --context="$GKE_CANARY_CLUSTER_CONTEXT" apply -f "$GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/out/"
kubectl --context="$GKE_PROD_CLUSTER_CONTEXT"   apply -f "$GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/out/"

# Check everything ok:
bin/kubectl-triune get all | grep "sol1"

#######################
# End of your code here
#######################
_allgood_post_script
echo Everything is ok.
