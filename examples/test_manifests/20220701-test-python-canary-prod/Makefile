

GKE_CONTEXT = gke_cicd-platinum-test001_europe-west6_cicd-canary
GKE_CONTEXT_NOPILOT = gke_cicd-platinum-test001_europe-north1_cicd-noauto-dev

up-autopilot:
	kubectl --context "${GKE_CONTEXT}" apply -f .


up-in-static-cluster:
	kubectl --context="${GKE_CONTEXT_NOPILOT}" apply -f .

set-ip-fw-ricc-only:
	dns-setup-palladius.sh app01-bifid.palladius.it 34.111.28.106
	dns-setup-palladius.sh app02-bifid.palladius.it # 34.111.28.106

curl-3-endpoints:
	echo 1. V1 canary: 
	curl http://app01-bifid.palladius.it/v1canary/whereami/pod_name 2>/dev/null
	echo 2. V2 prod: 
	curl http://app01-bifid.palladius.it/v2prod/whereami/pod_name 2>/dev/null
	echo 3. bifidus: 
	curl http://app01-bifid.palladius.it/whereami/pod_name 2>/dev/null
	