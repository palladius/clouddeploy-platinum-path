#!/bin/bash


source ../../.env.sh || fatal "Config doesnt exist please create .env.sh"


CLUSTER_NAME="${1:-no-cluster-provided-as-dollar1}"
GCLOUD_REGION="${2:-$GCLOUD_REGION}" # yup, it works! dflts to GCLOUD_REGION in .env First time in my life bash surprises me positively :)

# sample invokation@: ./powerup-cluster.sh cicd-noauto-dev europe-north1 

echo "Enabling Cluster for Turbo-Dmarzian stuff (MCS, .._)"
set -x
set -e


# 1. # enable required APIs (project level)
# gcloud services enable \
#     container.googleapis.com \
#     gkehub.googleapis.com \
#     multiclusterservicediscovery.googleapis.com \
#     multiclusteringress.googleapis.com \
#     trafficdirector.googleapis.com \
#     --project=$PROJECT_ID

# 1.5 (never did it before) from: https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity

gcloud container clusters update $CLUSTER_NAME \
    --region=$GCLOUD_REGION \
    --workload-pool=$PROJECT_ID.svc.id.goog

green 'To update your current NodePools to use WokkLoadIdendity use this magic and breaking command (note GKE_METADATA doesnt need change):'
echo gcloud container node-pools update NODEPOOL_NAME_CHANGEME \
    --cluster=$CLUSTER_NAME \
    --workload-metadata=GKE_METADATA

#2. register clusters to the fleet (cluster level)
gcloud container fleet memberships register "$CLUSTER_NAME" \
     --gke-cluster "$GCLOUD_REGION/$CLUSTER_NAME" \
     --enable-workload-identity \
     --project=$PROJECT_ID

gcloud container clusters get-credentials "$CLUSTER_NAME" --region "$GCLOUD_REGION" --project "$PROJECT_ID"
#kubectl config get-contexts

# should say yes :)
kubectl auth can-i '*' '*' --all-namespaces

#3. enable multi-cluster services
gcloud container fleet multi-cluster-services enable \
    --project $PROJECT_ID

#3.5 from https://cloud.google.com/kubernetes-engine/docs/how-to/multi-cluster-services
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
     --member "serviceAccount:$PROJECT_ID.svc.id.goog[gke-mcs/gke-mcs-importer]" \
     --role "roles/compute.networkViewer" \
     --project=$PROJECT_ID

#4.  enable gateway apis
kubectl apply -k "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.4.3"
# I should see FOUR not TWO:
kubectl get gatewayclass

#5. enable GKE gateway controller just in GKE01.
gcloud container fleet ingress enable \
    --config-membership=/projects/$PROJECT_ID/locations/global/memberships/$CLUSTER_NAME \
    --project=$PROJECT_ID

echo DONE.