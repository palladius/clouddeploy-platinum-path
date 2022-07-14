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
set -e

########################
# Add your code here
########################
#  We're going to use  - "__APPNAME__-sol1.example.io"    # kept for easy curl/documented static commands :)
DEFAULT_APP="app01"                       # app01 / app02
APP_NAME="${1:-$DEFAULT_APP}"
URL="$APP_NAME-sol1.example.io"

set -x

curl -H "host: $URL" 8.8.8.8 2>/dev/null


########################
# End of your code here
########################
#green 'Everything is ok. To use this amazing script, please download it from https://github.com/palladius/sakura'
_after_allgood_post_script
echo 'Everything is ok'
