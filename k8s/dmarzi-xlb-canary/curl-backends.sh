#!/bin/bash

DEFAULT_IP="34.149.231.48"
IP=${1:-$DEFAULT_IP}

set -x 

curl -H "host: store.example.io" "http://http://${IP}/" 2>/dev/null
curl -H "host: store.example.io" "http://http://${IP}/canary/" 2>/dev/null

#curl -s 'http://http://34.149.231.48:80/'
# 2>/dev/null

echo THE END.