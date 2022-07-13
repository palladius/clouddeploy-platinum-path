#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
#set -x
set -e

DEFAULT_APP="app01"
APP_NAME="${1:-$DEFAULT_APP}"

# K8S_IMAGE="skaf-app01-python-buildpacks"
# K8S_SELECTOR="app: ??" # or without app:
# Add your code here:

#kubectl config get-contexts | grep cicd | grep "$PROJECT_ID" | grep "$REGION"

# Example west/east
#kubectl apply --context gke-west-1 -f https://raw.githubusercontent.com/GoogleCloudPlatform/gke-networking-recipes/main/gateway/gke-gateway-controller/multi-cluster-gateway/store-west-1-service.yaml
#kubectl apply --context gke-west-2 -f https://raw.githubusercontent.com/GoogleCloudPlatform/gke-networking-recipes/main/gateway/gke-gateway-controller/multi-cluster-gateway/store-west-2-service.yaml

#kubectl apply --context "$GKE_CANARY_CLUSTER_CONTEXT" 
white "Usage (as I want it): $0 <APPNAME> <..>" 
red TODO ricc implement this for App01/02.
yellow Try to use app01 with solution01 and make it parametric in ARGV..
white "Now I proceed to apply solution 1 for: $APP_NAME. If wrong, call me with proper usage."

# ensure out dir exists..
mkdir -p "$GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/out/"

for TEMPLATE_FILE in "$GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/templates/"*.template.yaml ; do 
  DEST_FILE=$(echo "$TEMPLATE_FILE" | sed s:/templates/:/out/:) 
  echo "Hydrating template '$TEMPLATE_FILE' into this tmp out/ file: $DEST_FILE:"

  # set up additional variables
  PREFIX="${APP_NAME}" # maybe in the future PREFIX = APP-REGION
  REGION="${GCLOUD_REGION}"
  (
    echo '###########################################################'
    echo "# Created by $0 on `date` on `hostname`"
    echo "# Edit at your own risk as it'll be soon overwritten. Maybe." 
    echo '###########################################################'
    cat "$TEMPLATE_FILE"  | egrep -v '^#'  # remove comments
  )|
    sed -e "s/__MY_PROJECT_ID__/$PROJECT_ID/g" |
    sed -e "s/__PREFIX__/$PREFIX/g" |    
    sed -e "s/__APP_NAME__/$APP_NAME/g" |    
    sed -e "s/__MY_REGION__/$REGION/g" |
    sed -e "s/__MY_DOMAIN__/$MY_DOMAIN/g" |
    #sed -e "s/__MY_VERSION_/$CLOUD_DEPLOY_TEMPLATING_VER/g" |
    #egrep 'cluster|VER' | 
      tee "$DEST_FILE" >/dev/null
done
green Done.

yellow Now we can issue a kubectl on the out dir..
echo "TODO:  kubectl apply -f $GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/out/"

#######################
# End of your code here
#######################
_allgood_post_script
echo Everything is ok.
