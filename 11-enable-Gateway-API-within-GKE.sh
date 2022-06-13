#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
set -x
set -e


# CREO IN europe-west6
gcloud compute networks subnets create dmarzi-proxy \
    --purpose=REGIONAL_MANAGED_PROXY \
    --role=ACTIVE \
    --region="$GCLOUD_REGION" \
    --network='default' \
    --range='192.168.0.0/24'

# bingo! https://screenshot.googleplex.com/h5ZXAUgy5wWrvqh

# End of your code here
echo YAY. Tutto ok.

# kubectl apply -k "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.4.3"
# kubectl get gatewayclass



# WORKS ONLY WITH MULTIPLE CLUSTERS IN THE SAME REGION
# Enable (multi-cluster Gateways)[https://cloud.google.com/kubernetes-engine/docs/how-to/enabling-multi-cluster-gateways]
# Blue-Green https://cloud.google.com/kubernetes-engine/docs/how-to/deploying-multi-cluster-gateways#blue-green

1. # enable required APIs
gcloud services enable \
    container.googleapis.com \
    gkehub.googleapis.com \
    multiclusterservicediscovery.googleapis.com \
    multiclusteringress.googleapis.com \
    trafficdirector.googleapis.com \
    --project=PROJECT_ID

2. # register clusters to the fleet
gcloud container fleet memberships register CLUSTER_1 \
     --gke-cluster CLUSTER_1_LOCATION/CLUSTER_1 \
     --enable-workload-identity \
     --project=PROJECT_ID

gcloud container fleet memberships register CLUSTER_2 \
     --gke-cluster CLUSTER_2_LOCATION/CLUSTER_2 \
     --enable-workload-identity \
     --project=PROJECT_ID

3. #enable multi-cluster services
gcloud container fleet multi-cluster-services enable \
    --project PROJECT_ID

gcloud projects add-iam-policy-binding PROJECT_ID \
     --member "serviceAccount:PROJECT_ID.svc.id.goog[gke-mcs/gke-mcs-importer]" \
     --role "roles/compute.networkViewer" \
     --project=PROJECT_ID

4. # enable gateway apis
kubectl apply -k "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.4.3"
kubectl get gatewayclass

5. #enable GKE gateway controller
gcloud container fleet ingress enable \
    --config-membership=/projects/PROJECT_ID/locations/global/memberships/CLUSTER_1 \
    --project=PROJECT_ID

gcloud projects add-iam-policy-binding PROJECT_ID \
     --member "serviceAccount:service-PROJECT_NUMBER@gcp-sa-multiclusteringress.iam.gserviceaccount.com" \
     --role "roles/container.admin" \
     --project=PROJECT_ID
     

6. # apply the gateway configuration on CLUSTER_1

kind: Gateway
apiVersion: gateway.networking.k8s.io/v1alpha2
metadata:
  name: apps-http
spec:
  gatewayClassName: gke-l7-rilb-mc
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      kinds:
      - kind: HTTPRoute
      namespaces:
        from: Selector
        selector:
          matchLabels:
            gateway: apps-http

7. Export Services
CLUSTER_1
---
apiVersion: v1
kind: Service
metadata:
  name: app-web-01
spec:
  ports:
  - port: 8080
    name: http
  selector:
    app: app01-web
---
kind: ServiceExport
apiVersion: net.gke.io/v1
metadata:
  name: app-web-01
  namespace: default

CLUSTER_2

---
apiVersion: v1
kind: Service
metadata:
  name: app-web-02
spec:
  ports:
  - port: 9292
    targetPort: 9292
  selector:
    app: app02-ruby
---
kind: ServiceExport
apiVersion: net.gke.io/v1
metadata:
  name: app-web-02
  namespace: default


8.

kind: HTTPRoute
apiVersion: gateway.networking.k8s.io/v1alpha2
metadata:
  name: internal-store-route
  namespace: default
  labels:
    gateway: apps-http
spec:
  parentRefs:
  - kind: Gateway
    namespace: default
    name: apps-http
  hostnames:
  - "apps.example.internal"
  rules:
  - backendRefs:
    # 90% of traffic to store-west-1 ServiceImport
    - name: app-web-01
      group: net.gke.io
      kind: ServiceImport
      port: 8080
      weight: 90
    # 10% of traffic to store-west-2 ServiceImport
    - name: app-web-02
      group: net.gke.io
      kind: ServiceImport
      port: 8080
      weight: 10