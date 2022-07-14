
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
	@echo Testing kustomize for both apps..
	make -C out all

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
	kustomize build apps/app02/k8s/01dev/     > t.app02-ruby.kust.dev
	kustomize build apps/app02/k8s/02staging/ > t.app02-ruby.kust.stag
	kustomize build apps/app02/k8s/03canary/  > t.app02-ruby.kust.cana
	kustomize build apps/app02/k8s/04prod/    > t.app02-ruby.kust.prod
	@echo Showing the diff between PROD and CANARY manifests:
	diff t.app02-ruby.kust.prod t.app02-ruby.kust.cana
	echo Done.


first-half:
	./00-init.sh
	./01-set-up-GKE-clusters.sh
	./02-setup-skaffold-cache-bucket.sh
	./03-configure-artifact-repo-and-docker.sh
	./04-status.sh
	./05-IAM-enable-cloud-build.sh
	#./06-cloud-build-locally.sh
	echo All good: first half done.

second-half:
	./07-create-cloud-build-triggers.sh
	./08-cloud-deploy-setup.sh
	./09-show-latest-successful-releases.sh app01
	./09-show-latest-successful-releases.sh app02
	./10-auto-promote-dev-to-staging.sh
	./11-solution0-enable-Gateway-API-with-ILB.sh
	./12-solution0-kubectl-apply-stuff.sh
	./13-solution1-setup-gateway-API.sh
	./14-solution1-check.sh
	./15-solution2-xlb-GFE3-traffic-split.sh
	./16-solution2-test-by-curling-N-times.sh

breadcrumb-navigation:
	@echo "I hope youre a fan of Hansel and Gretel too. As Zoolander fan, I am."
	ls -al .executed_ok.*

clean:
	echo 'Removing tmp files created by scripts..'
	rm k8s/*/out/*.yaml

# not sure i want to do this...
#rm .executed.*
