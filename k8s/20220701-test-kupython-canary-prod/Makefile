

GKE_CONTEXT = gke_cicd-platinum-test001_europe-west6_cicd-canary
GKE_CONTEXT_NOPILOT = gke_cicd-platinum-test001_europe-north1_cicd-noauto-dev

up-autopilot:
	kubectl --context "${GKE_CONTEXT}" apply -f .


up-in-static-cluster:
	kubectl --context="${GKE_CONTEXT_NOPILOT}" apply -f .
