#!/bin/bash

function _fatal() {
    echo "$*" >&1
    exit 42
}

# Created with codelabba.rb v.1.7a
source .env.sh || _fatal 'Couldnt source this'
#set -e

########################
# Add your code here
########################
# cleaning up OLD stuff
yellow 'Cemetery Gates(TM) script'

BAD_HTTP_ROUTES="sol1-app01-eu-w1 app01-eu-w1-sol1"
BAD_DEPLOYMENTS="sol1-app01-kupython-canary sol1-app02-kuruby-canary sol1-app02-kuruby-prod app01-sol2-svc-prod app01-sol2-svc-canary app02-sol2-svc-prod app02-sol2-svc-canary"
BAD_GATEWAYS="sol1--ext-gw"
BAD_SERVICES="sol1--common-svc"

#set -x

#bin/kubectl-canary-and-prod delete httproute sol1-app01-eu-w1
#bin/kubectl-canary-and-prod delete httproute app01-eu-w1-sol1
for X in $BAD_HTTP_ROUTES ; do
    bin/kubectl-triune delete httproute "$X"
done

# 202207-19 Just talked to Alex, looks like i do NOt need the deployments in my various solutions, let me REMOVE them
# and just have the services pointing at my prod stuff :) So __IMAGE__ is pointless :)
for ITER_DEPL in $BAD_DEPLOYMENTS ; do
    bin/kubectl-triune delete deployment "$ITER_DEPL"
done

# bad services
#bin/kubectl-triune delete service service/sol1--common-svc

for ITER_GATEWAY in $BAD_GATEWAYS ; do
    bin/kubectl-triune delete gateway "$ITER_GATEWAY"
done


########################
# End of your code here
########################
#green 'Everything is ok. To use this amazing script, please download it from https://github.com/palladius/sakura'
_allgood_post_script
echo 'Everything is ok'
