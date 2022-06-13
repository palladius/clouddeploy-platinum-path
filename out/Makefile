

all: kustomize-app01 kustomize-app02

kustomize-app01:
	mkdir -p app01/
	@echo Python has not been kustomized yet sorry.
	kustomize build   ../apps/app01/k8s/dev/     > app01/app01-python-dev.yaml

	@echo Showing the NAME between PROD and CANARY manifests:
#rgrep app: app01/
	ls -al app01/*
	cat app01/* | lolcat
	echo Done.

kustomize-app02:
	mkdir -p app02/
	kustomize build ../apps/app02/k8s/01dev/     > app02/app02-ruby-dev.yaml
	kustomize build ../apps/app02/k8s/02staging/ > app02/ruby-stag.yaml
	kustomize build ../apps/app02/k8s/03canary/  > app02/ruby-cana.yaml
	kustomize build ../apps/app02/k8s/04prod/    > app02/ruby-prod.yaml
	@echo Showing the NAME in all manifests:
	rgrep app: app02/
	echo Done.

