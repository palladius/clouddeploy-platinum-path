#!/bin/bash

function _fatal() {
    echo "$*" >&1
    exit 42
}
function _after_allgood_post_script() {
    echo "[$0] All good on $(date)"
    CLEANED_UP_DOLL0="$(basename $0)"
    touch .executed_ok."$CLEANED_UP_DOLL0".touch
}

# Created with codelabba.rb v.1.7a
source .env.sh || _fatal 'Couldnt source this'
#set -e

########################
# Add your code here
########################
# cleaning up OLD stuff
yellow 'Cemetery Gates(TM) script'

set -x

#bin/kubectl-canary-and-prod delete httproute sol1-app01-eu-w1
bin/kubectl-canary-and-prod delete httproute app01-eu-w1-sol1



########################
# End of your code here
########################
#green 'Everything is ok. To use this amazing script, please download it from https://github.com/palladius/sakura'
_after_allgood_post_script
echo 'Everything is ok'
