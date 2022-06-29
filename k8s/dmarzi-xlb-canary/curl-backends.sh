#!/bin/bash

DEFAULT_IP="34.149.231.48"
IP=${1:-$DEFAULT_IP}


echo -en 'Autoinferring IP would yield this: '
gcloud compute forwarding-rules list | grep gkegw | awk '{print $2}' | lolcat 

set -x 

curl -H "host: store.example.io" "http://http://${IP}/" 2>/dev/null
curl -H "host: store.example.io" "http://http://${IP}/canary/" 2>/dev/null

echo THE END.