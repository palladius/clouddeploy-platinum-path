
test:
	@echo 'Running tests for ALL my sub apps - dopes it even make sense?'
# TODO automate for every dir..
	cat app01/VERSION
	cat app02/VERSION
	echo Everything is in order from here.

.PHONY: tmp clean

tmp: kustomize
kustomize:
	mkdir -p tmp/

	# kustomize build app01/k8s/overlays/dev/    > tmp/app01-tmp-dev.yaml
	# kustomize build app01/k8s/overlays/staging/> tmp/app01-tmp-staging.yaml
	# kustomize build app01/k8s/overlays/canary/ > tmp/app01-tmp-canary.yaml
	# kustomize build app01/k8s/overlays/production/   > tmp/app01-tmp-production.yaml
	# diff tmp/app01-tmp-prod.yaml tmp/app01-tmp-canary.yaml | tee tmp/app01-prod-vs-canary.diff >/dev/null

	# kustomize build app02/k8s/overlays/dev/    > tmp/app02-tmp-dev.yaml
	# kustomize build app02/k8s/overlays/staging/> tmp/app02-tmp-staging.yaml
	# kustomize build app02/k8s/overlays/canary/ > tmp/app02-tmp-canary.yaml
	# kustomize build app02/k8s/overlays/production/   > tmp/app02-tmp-production.yaml
	# diff tmp/app02-tmp-prod.yaml tmp/app02-tmp-canary.yaml | tee tmp/app02-prod-vs-canary.diff >/dev/null

	./kustomize-dump.sh 'app03'
	./kustomize-dump.sh 'app02'
	./kustomize-dump.sh 'app01'

clean:
	rm tmp/*
