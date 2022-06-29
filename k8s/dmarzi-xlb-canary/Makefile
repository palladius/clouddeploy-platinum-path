
GKE_CONTEXT = gke_cicd-platinum-test001_europe-west6_cicd-canary
KUBECTL = kubectl --context "${GKE_CONTEXT}" 
# -n store

show:
	${KUBECTL} get svc | grep store
	${KUBECTL} get gateways | grep store
#kubectl --context gke_cicd-platinum-test001_europe-west6_cicd-canary -n store describe gateways/external-http
	${KUBECTL} describe gateways/external-store-http

up:
	@echo NOTE this is an AutoPilot cluster. Some MVC services might NOT work.
	${KUBECTL} apply -f .


# kubectl config get-contexts 
#gcloud container clusters get-credentials tmp-manhouse --zone europe-west4-b --project cicd-platinum-test001
up-in-static-cluster:
	kubectl --context=gke_cicd-platinum-test001_europe-west4-b_tmp-manhouse apply -f .