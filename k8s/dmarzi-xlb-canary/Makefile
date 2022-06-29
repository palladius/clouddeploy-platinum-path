
GKE_CONTEXT = gke_cicd-platinum-test001_europe-west6_cicd-canary
KUBECTL = kubectl --context "${GKE_CONTEXT}" 
# -n store

show:
	${KUBECTL} get svc | grep store
	${KUBECTL} get gateways | grep store
#kubectl --context gke_cicd-platinum-test001_europe-west6_cicd-canary -n store describe gateways/external-http
	${KUBECTL} describe gateways/external-store-http

up:
	${KUBECTL} apply -f .