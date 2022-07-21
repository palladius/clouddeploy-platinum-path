#!/bin/bash

function _fatal() {
    echo "$*" >&2
    exit 42
}
function _after_allgood_post_script() {
    echo "[$0] All good on $(date)"
    CLEANED_UP_DOLL0="$(basename $0)"
    touch .executed_ok."$CLEANED_UP_DOLL0".touch
}

# This is just for me to go through the created entities and see if its all good.
function troubleshoot_solution1_entities() {
    white "== Lets investigate entities in PROD =="
    export DEBUG="false"
    bin/kubectl-prod get GatewayClass
    bin/kubectl-prod get Gateway
    #bin/kubectl-prod describe Gateway sol1-app01-eu-w1-ext-gw
    bin/kubectl-prod get httproute | grep sol1
    yellow Maybe describe one GOOD and one BAD route and see what happens..


}
# ARGS: 'canary' "$NAME" "$ADDRESS"
function _manage_gateway_endpoint() {
    TARGET="$1"
    GATEWAY_NAME="$2"
    ENDPOINT_IP="$3"
    TEST_URL="${4:-sol1-passepartout.example.io}"
    #green "[SOL1::$TARGET] Found a nice Endpoint for '$2': $3. curling now=$URL"
    #echo -en "[$TARGET] '$2'\t" # $3. curling now=$URL"
    _deb "command:         curl -s -H 'host: $TEST_URL' 'http://$ENDPOINT_IP/statusz'" # for me tro try from CLI :)
    set -x
        curl_result="$( curl -s -H "host: $TEST_URL" "http://$ENDPOINT_IP/statusz" 2>&1 )" # sometimes it has no \n so wrapping here.
    set +x
    echo "[$TARGET] $GATEWAY_NAME CURL $TEST_URL to $ENDPOINT_IP => $curl_result" | bin/rcg "default backend - 404" "BOLD . RED"

}
# Created with codelabba.rb v.1.7a
source .env.sh || _fatal 'Couldnt source this'
set -e

########################
# Add your code here
########################
#  We're going to use  - "sol1-__APPNAME__.example.io"    # kept for easy curl/documented static commands :)
DEFAULT_APP="app01"                       # app01 / app02
APP_NAME="${1:-$DEFAULT_APP}"
K8S_APP_SELECTOR="${AppsInterestingHash["$APP_NAME-SELECTOR"]}"
K8S_APP_IMAGE="${AppsInterestingHash["$APP_NAME-IMAGE"]}"

URL="sol1-$APP_NAME.example.io"
PREFIX="${APP_NAME}-${DEFAULT_SHORT_REGION}" # maybe in the future PREFIX = APP-REGION

#bin/kubectl-canary apply -f "$GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/out/"
#bin/kubectl-prod   apply -f "$GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/out/"

if "$DEBUG" ; then
    echo "APP_NAME:  $APP_NAME"
    echo "URL:       $URL"
    echo "PREFIX:    $PREFIX"
    echo K8S_APP_SELECTOR: $K8S_APP_SELECTOR
    echo K8S_APP_IMAGE: $K8S_APP_IMAGE


fi

#set -x
yellow "Watch in awe this:"
bin/kubectl-triune get gateways | egrep "NAME|sol1"


# ReApply k8s manifests:
white "Silently [re-]applying k8s manifests in $GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/ .."
{
    # Disabling Exit on error since error can happen here...
    #set +e
    make clean
    smart_apply_k8s_templates "$GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR"
    #cat "$GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/"out/*.yaml | grep '__' # 2>&1

    # Now checking fir UGLY mistakes like:
    # [PROD] sol1--ext-gw              gke-l7-gxlb   34.149.148.162   True    100m
    # cat "$GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/out/"*.yaml | grep '__'  &&
    #     _fatal "ERR01. Double underscore smells like a needed variable was not found. Exiting to be on safe side" ||
    #         echo Ok. No errors. All templated variables seem to have been done.
    # cat "$GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/out/"*yaml | rgrep -v '---' | grep -- '--'  &&
    #     _fatal "ERR02. Double dash smells like an EMPTY STRING variable was instanced. Exiting to be on safe side" ||
    #         echo Ok. No errors. All templated variables seem to have been done.

#    bin/kubectl-canary apply -f "$GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/out/"
#    bin/kubectl-prod   apply -f "$GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/out/"
    bin/kubectl-dev apply -f "$GKE_SOLUTION1_XLB_PODSCALING_SETUP_DIR/out/"


    echo All Good.
    #set -e
} #1>/dev/null


troubleshoot_solution1_entities

### OPutput should look like this:
# bin/kubectl-prod get gateway
# [DEBUG] DEBUG has been enabled! Please change to DEBUG=FALSE in your .env.sh to remove this. Some impotant fields:
# [DEBUG] PROJECT_ID:        'cicd-platinum-test002'
# [DEBUG] ACCOUNT:           'palladiusbonton@gmail.com'
# [DEBUG] GITHUB_REPO_OWNER: 'palladius'
# [DEBUG] GCLOUD_REGION:     'europe-west1'
# [DEBUG] GKE_REGION:        'europe-west1'
# [PROD] W0719 11:22:31.834156 1998707 gcp.go:120] WARNING: the gcp auth plugin is deprecated in v1.22+, unavailable in v1.25+; use gcloud instead.
# [PROD] To learn more, consult https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
# [PROD] NAME                      CLASS         ADDRESS         READY   AGE
# [PROD] sol1-app01-eu-w1-ext-gw   gke-l7-gxlb   34.111.78.196   True    39m

# Making sure the IP address sis up (True), it belongs to the APP called by ARGV[1] and that it is solution 1 stufh
# white "== Curling PRD/CAN endpoints now =="
# bin/kubectl-prod get gateway | grep sol1-app | grep True | grep "$APP_NAME" | while read USELESS_HEADER NAME CLASS ADDRESS READY AGE ; do
#     _manage_gateway_endpoint 'prod' "$NAME" "$ADDRESS"
# done
# bin/kubectl-canary get gateway | grep sol1-app | grep True |  grep "$APP_NAME" | while read USELESS_HEADER NAME CLASS ADDRESS READY AGE ; do
#     _manage_gateway_endpoint 'canary' "$NAME" "$ADDRESS"
# done

white "== Curling DEV endpoints now =="
bin/kubectl-dev get gateway | grep sol1 | grep True | grep "$APP_NAME" | while read USELESS_HEADER NAME CLASS ADDRESS READY AGE ; do
    _manage_gateway_endpoint 'prod' "$NAME" "$ADDRESS"
done

# yellow "Warning, IP address is currently hard-coded :/"
# #LB_NAME="http-svc9010-lb"
# SOL1_LB_NAME_FOR_MY_APP="sol1-$APP_NAME-$DEFAULT_SHORT_REGION-gke-l7-gxlb"
# #ENDPOINT_IP="34.160.173.24:80"	# https://console.cloud.google.com/net-services/loadbalancing/details/httpAdvanced/http-svc9010-lb?project=cicd-platinum-test001
# ENDPOINT_IP='1.2.3.4'



# yellow "TODO check for a LB called SOL1_LB_NAME_FOR_MY_APP=$SOL1_LB_NAME_FOR_MY_APP. Once you do, youre done and you can subsitute it to this static IP."
# curl -H "host: $URL" "$ENDPOINT_IP/canary" 2>/dev/null
# curl -H "host: $URL" "$ENDPOINT_IP/prod" 2>/dev/null


########################
# End of your code here
########################
#green 'Everything is ok. To use this amazing script, please download it from https://github.com/palladius/sakura'
_after_allgood_post_script
echo 'Everything is ok'
