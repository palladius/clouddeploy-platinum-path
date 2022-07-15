
up:
	colorastdouterr kubectl apply -f .

check:
	kubectl --context gke_cicd-platinum-test001_europe-west6_cicd-canary -n store describe gateways/external-http 
	kubectl --context gke_cicd-platinum-test001_europe-west6_cicd-canary -n store get svc 
