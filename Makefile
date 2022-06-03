
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

build: cloud-build-locally

hiroshima:
	@echo deleting all GKE resources...
	kubectl delete all
