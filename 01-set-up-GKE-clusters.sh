#!/bin/bash
function _fatal() {
    echo "$*" >&2
    exit 42
}
# Created with codelabba.rb v.1.4a
source .env.sh || _fatal "Config doesnt exist please create .env.sh"
set -e

# Add your code here:

# Creating network as per Alex comment:
proceed_if_error_matches 'already exists' \
  gcloud compute networks create 'default' --subnet-mode=auto #       --mtu=1460

echo "Here we set up a few clusters, this will take a few minutes. Good time to get a coffee or tea. Note we set up everything in region $REGION" | lolcat

gcloud auth configure-docker $REGION-docker.pkg.dev

##############################################################################
# Uncomment this if you want to create clusters NOT in autopilot (will cost more
# but will be more responsive to pods creation). Also capacity is kind of checked
# at birth rather than at usage. If you want to use it INSTEAD you need to change
# the cluster names to the shorter ones below ("cicd-dev", ..). I kept this names
# to have both fleets of 3 clusters in parallel to test functionalities.
##############################################################################

# DEV
echo
white 'Creating THREE Clusters. This might take 5-10min... good time for a coffee 🕰'
echo

set -x
for STANDARD_CLUSTER_NAME in "cicd-dev" "cicd-canary" "cicd-prod" ; do
  # 2022-07-22: changed NumNodes from 3 to 2. TESTED_OK
  # 2022-07-22: Added Workload Identity by defautl. Not tested yet!
  # docs: https://cloud.google.com/sdk/gcloud/reference/container/clusters/create
  # Note:
  proceed_if_error_matches 'ResponseError: code=409, message=Already exists:' \
    gcloud container --project "$PROJECT_ID" clusters create "$STANDARD_CLUSTER_NAME" --region "$REGION" \
      --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/default" \
      --num-nodes=2 \
      --workload-pool="$PROJECT_ID.svc.id.goog" \
      --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22" --enable-ip-alias
done
set +x

# proceed_if_error_matches 'ResponseError: code=409, message=Already exists:' \
# gcloud container --project "$PROJECT_ID" clusters create "cicd-dev" --region "$REGION" \
#   --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/default" \
#   --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22" --enable-ip-alias
# # CANARY
# gcloud container --project "$PROJECT_ID" clusters create "cicd-canary" --region "$REGION" \
#   --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/default" \
#   --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22" --enable-ip-alias
# PROD
# gcloud container --project "$PROJECT_ID" clusters create "cicd-noauto-prod" --region "$REGION" \
#   --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/default" \
#   --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22" --enable-ip-alias

#############################################################
# Create 3 clusters in autopilot (the ones we use for our demo)
#############################################################
# 1. DEV
proceed_if_error_matches 'ResponseError: code=409, message=Already exists:' \
gcloud container --project "$PROJECT_ID" clusters create-auto "cicd-dev" --region "$GKE_REGION" \
  --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$GKE_REGION/subnetworks/default" \
  --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22"

# 2. CANARY (Similar to prod but smaller)
proceed_if_error_matches 'ResponseError: code=409, message=Already exists:' \
  gcloud container --project "$PROJECT_ID" clusters create-auto "cicd-canary" --region "$GKE_REGION" \
    --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$GKE_REGION/subnetworks/default" \
    --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22" # --labels "env=prod"

# 3. PROD
proceed_if_error_matches 'ResponseError: code=409, message=Already exists:' \
gcloud container --project "$PROJECT_ID" clusters create-auto "cicd-prod" --region "$GKE_REGION" \
  --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$GKE_REGION/subnetworks/default" \
  --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22" # --labels "env=prod"


for ITER_CLUSTER in cicd-canary cicd-prod cicd-dev ; do
   gcloud container clusters get-credentials "$ITER_CLUSTER" --region "$GKE_REGION"
   #2>/dev/null ||
   #    yellow "This will fail before you run step 01... so no biggie if this fails."
done

#############################################################
# Create Artifact Registry
#############################################################

proceed_if_error_matches 'the repository already exists' \
  gcloud --project "$PROJECT_ID" artifacts repositories create $ARTIFACT_REPONAME \
    --location="$REGION" --repository-format=docker

# End of your code here. `green` script can be found in "palladius/sakura" but also here in `bin/`
_allgood_post_script
echo Everything is ok.
