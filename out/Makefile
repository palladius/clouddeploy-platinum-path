

all: kustomize-app01 kustomize-app02

kustomize-app01:
	mkdir -p app01/
	@echo Python has not been kustomized yet sorry.
	kustomize build   ../apps/app01/k8s/dev/     > app01/t.python-dev.yaml
	kustomize build   ../apps/app01/k8s/staging/ > app01/t.python-staging.yaml
	kustomize build   ../apps/app01/k8s/canary/  > app01/t.python-canary.yaml
	kustomize build   ../apps/app01/k8s/prod/    > app01/t.python-prod.yaml

	@echo Showing the NAME between PROD and CANARY manifests:
#rgrep app: app01/
	ls -al app01/*
	cat app01/* | lolcat
	echo Done.

kustomize-app02:
	mkdir -p app02/
	kustomize build ../apps/app02/k8s/01dev/     > app02/t.ruby-dev.yaml
	kustomize build ../apps/app02/k8s/02staging/ > app02/t.ruby-stag.yaml
	kustomize build ../apps/app02/k8s/03canary/  > app02/t.ruby-cana.yaml
	kustomize build ../apps/app02/k8s/04prod/    > app02/t.ruby-prod.yaml
	@echo Showing the NAME in all manifests:
	rgrep app: app02/
	echo Done.

clean:
	rm t.*.yaml app0*/*.yaml