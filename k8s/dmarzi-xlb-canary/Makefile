
GKE_CONTEXT = gke_cicd-platinum-test001_europe-west6_cicd-canary
#GKE_CONTEXT_NOPILOT = gke_cicd-platinum-test001_europe-west4-b_tmp-manhouse
GKE_CONTEXT_NOPILOT = gke_cicd-platinum-test001_europe-north1_cicd-noauto-dev
KUBECTL = kubectl --context "${GKE_CONTEXT}" 
# -n store

# gcloud components install gke-gcloud-auth-plugin
# https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
# USE_GKE_GCLOUD_AUTH_PLUGIN=True => added to .bashrc

initialize-gke-auth:
	@echo 'read this article: https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke'
	@gcloud container clusters get-credentials cicd-canary --region europe-west6

show: curl-backend initialize-gke-auth
	kubectl config get-contexts
	${KUBECTL} get svc | grep store
	${KUBECTL} get gateways
	${KUBECTL} get httproutes
# | grep store
#kubectl --context gke_cicd-platinum-test001_europe-west6_cicd-canary -n store describe gateways/external-http
	${KUBECTL} describe gateways/external-store-http

up-autopilot-DOESNTWORK:
	@echo NOTE this is an AutoPilot cluster. Some MVC services might NOT work.
	${KUBECTL} apply -f .

# kubectl config get-contexts 
#gcloud container clusters get-credentials tmp-manhouse --zone europe-west4-b --project cicd-platinum-test001
up-in-static-cluster:
	kubectl --context="${GKE_CONTEXT_NOPILOT}" apply -f .

curl-all-backends:
	./curl-all-backends.sh

# show alternance between the two..
watch-curl-backend-bifidus:
#	while true; do curl -s http://store-bifido.palladius.it/ | egrep 'pod_name"' ; sleep 1; done
	./curl-bifidus-endpoint-continuously.sh 20