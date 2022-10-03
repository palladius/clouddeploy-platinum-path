#!/bin/bash
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Created with codelabba.rb v.1.4a
source .env.sh || fatal "Config doesnt exist please create .env.sh"

# STATUS script should NOT have -e enabled :)
#set -e


function show_k8s_stuff() {
    # I have 3 clusters and for each I want to show things..
    for CONTEXT in $GKE_DEV_CLUSTER_CONTEXT $GKE_CANARY_CLUSTER_CONTEXT $GKE_PROD_CLUSTER_CONTEXT ; do
        yellow "== ClusterContext: $CONTEXT =="
        # https://stackoverflow.com/questions/33942709/run-a-single-kubectl-command-for-a-specific-project-and-cluster
        # if it doesnt work this should work: kubectl config use-context CONTEXT_NAME
        # RIP echo_do
        echo "kubectl --context=$CONTEXT get service,gatewayclass 2>/dev/null"
             kubectl --context="$CONTEXT" get service,gatewayclass 2>/dev/null ||
                echo "Possibly empty output for cluster in $CONTEXT"
    done
}

function show_gcloud_stuff() {
    echo "+ Let's count the images for each artifact:"
    gcloud artifacts docker images list "$ARTIFACT_LONG_REPO_PATH" | awk '{print $1}' | sort | uniq -c #  || echo ''
    gcloud deploy delivery-pipelines list | egrep "name:|targetId" #|| echo ''
    gcloud compute target-http-proxies list # || echo ''
}

# Add your code here:
#SHOW_VERBOSE_STUFF="false" = ${1:-}
#SHOW_GCLOUD_ENTITIES="true"
#SHOW_DEVCONSOLE_LINKS="${SHOW_DEVCONSOLE_LINKS:-true}"
#SHOW_KUBERNETES_STUFF="true"
#SHOW_SKAFFOLD_STUFF="true"

SHOW_VERBOSE_STUFF="${SHOW_VERBOSE_STUFF:-false}"
SHOW_GCLOUD_ENTITIES="${SHOW_GCLOUD_ENTITIES:-true}"
SHOW_DEVCONSOLE_LINKS="${SHOW_DEVCONSOLE_LINKS:-true}"
SHOW_KUBERNETES_STUFF="${SHOW_KUBERNETES_STUFF:-true}"
SHOW_SKAFFOLD_STUFF="${SHOW_SKAFFOLD_STUFF:-true}"

echo "SHOW_VERBOSE_STUFF:     $SHOW_VERBOSE_STUFF"
echo "SHOW_GCLOUD_ENTITIES:   $SHOW_GCLOUD_ENTITIES"
echo "SHOW_DEVCONSOLE_LINKS:  $SHOW_DEVCONSOLE_LINKS"
echo "SHOW_KUBERNETES_STUFF:  $SHOW_KUBERNETES_STUFF"
echo "SHOW_SKAFFOLD_STUFF:    $SHOW_SKAFFOLD_STUFF"

echo "+ REGION for DEPLOY:          $CLOUD_DEPLOY_REGION"
echo "+ REGION for GKE:             $GKE_REGION"
echo "+ REGION for EVERYTHING ELSE: $REGION"

#echo TODO kubectl get pods (TODO first add correct context)
#kubectl get pods,service
gcloud beta builds triggers list --region $REGION

if [ "true" = "$SHOW_SKAFFOLD_STUFF" ]; then
    echo "== skaffold info ==" | lolcat
    skaffold config list
fi

if [ "true" = "$SHOW_DEVCONSOLE_LINKS" ]; then
    echo "== DevConsole useful links START (if you are a UI kind of person) ==" | lolcat

    white "[GKE] k8s Workloads: $DEVCONSOLE/kubernetes/workload/overview?&project=$PROJECT_ID"
    white "[Cloud Build] Global Builds (our triggers): $DEVCONSOLE/cloud-build/builds;region=global?&project=$PROJECT_ID"
    white "[Cloud Build] Regio Builds (from CDeploy): $DEVCONSOLE/cloud-build/builds;region=$REGION?&project=$PROJECT_ID"
    white "[Cloud Build] Triggers: $DEVCONSOLE/cloud-build/triggers;region=global?project=$PROJECT_ID"
    white "[Cloud Deploy] Pipelines: $DEVCONSOLE/deploy/delivery-pipelines?project=$PROJECT_ID"
    white "Cloud Source Repositories (CSR): https://source.cloud.google.com/$PROJECT_ID"
    white "Network Endpoint Groups (NEGs): $DEVCONSOLE/compute/networkendpointgroups/list?project=$PROJECT_ID"
    white "Load Balancers (HTTP LBs): $DEVCONSOLE/net-services/loadbalancing/list/loadBalancers?project=$PROJECT_ID"
    # Super important for things that killed my script 15: Load balancing components
    white "Load Balancers (BE comps): $DEVCONSOLE/net-services/loadbalancing/advanced/backendServices/list?project=$PROJECT_ID"
    echo "== DevConsole useful links END =="
fi

if [ "true" = $SHOW_KUBERNETES_STUFF ] ; then
    echo "== Kubernetes Stuff ==" | lolcat
    show_k8s_stuff
fi

# Docs: https://cloud.google.com/sdk/gcloud/reference/beta/artifacts/docker
if [ "true" = "$SHOW_GCLOUD_ENTITIES" ] ; then
    echo "== GCloud entities (SHOW_GCLOUD_ENTITIES=$SHOW_GCLOUD_ENTITIES) ==" | lolcat
    show_gcloud_stuff
fi
if [ "true" = "$SHOW_VERBOSE_STUFF" ] ; then
    echo "== Verbose Stuff ==" | lolcat

    gsutil ls -l "gs://$SKAFFOLD_BUCKET/skaffold-cache/"
    gcloud beta builds triggers list --region $REGION
    skaffold config list
fi

# End of your code here
_allgood_post_script
echo Everything is ok.
