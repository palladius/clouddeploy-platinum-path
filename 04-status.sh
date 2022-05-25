#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
set -x
set -e

# Add your code here:

#echo TODO kubectl get pods (TODO first add correct context)
gsutil ls -l "gs://$SKAFFOLD_BUCKET/skaffold-cache/"
kubectl get pods,service
gcloud beta builds triggers list --region europe-west6
skaffold config list





# End of your code here
verde Tutto ok.
