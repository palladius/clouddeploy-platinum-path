
README:
	cat Makefile

status:
	bash 04-status.sh

dev:
	echo Only works after step 4..
	skaffold dev

all: 
	bash 0*.sh
# build:
# 	skaffold build --module=app01
# 	skaffold build
dev-python: dev-app01

dev-ruby:  dev-app02

dev-app01:
	skaffold dev --module app01
dev-app02:
	skaffold dev --module app02

cloud-build-locally:
	./06-cloud-build-locally.sh app01
	./06-cloud-build-locally.sh app02

# calls Cloud Build script and does the whole script thingy
build-local: cloud-build-locally

# just calls the bash script with proper ENV to fake it.
fake-build-shell-script:
	FAKEIT=true ./cloud-build/01-on-commit-build.sh app01 emilia-romagna-1

hiroshima:
	@echo deleting all GKE resources...
	kubectl delete all


show-latest-succesful-releases:
	./09-show-latest-successful-releases.sh app01
	./09-show-latest-successful-releases.sh app02

promote-all-dev-to-staging:
	./10-auto-promote-dev-to-staging.sh app01
	./10-auto-promote-dev-to-staging.sh app02
promote-all-staging-to-canary:
	./10-auto-promote-dev-to-staging.sh app01 staging canary
	./10-auto-promote-dev-to-staging.sh app02 staging canary
promote-all-canary-to-prod:
	echo 'Are you crazy?!? This cannot be done, the world could explode. Use the UI instead!'
	# Really i dont trust my scripts enough to possibly break PROD :)
	/bin/false

tests:
	@echo Ensuring tests pass for both applications.. as make test launched in their folder.
#	@echo Testin app01...
	make -C apps/app01/ test
#	@echo Testin app02...
	make -C apps/app02/ test
	
# I didnt know it was so straightfwd! Install: https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/
kustomize-install:
	curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

kustomize-test:
	kustomize build apps/app02/k8s/04prod/ >/dev/null
	kustomize build apps/app02/k8s/03canary/ >/dev/null
	kustomize build apps/app02/k8s/01dev/ >/dev/null
	kustomize build apps/app02/k8s/02staging/ >/dev/null
	@echo Done. TODO ricc diff the two now.

kustomize-ruby-diff-prod-and-canary:
	kustomize build apps/app02/k8s/04prod/ > t.kust.prod
	kustomize build apps/app02/k8s/03canary/ > t.kust.canary 
	@echo Showing the diff between PROD and CANARY manifests:
	diff t.kust.prod t.kust.canary
	echo Done.
