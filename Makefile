
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

tests:
	@echo Ensuring tests pass for both applications.. as make test launched in their folder.
#	@echo Testin app01...
	make -C apps/app01/ test
#	@echo Testin app02...
	make -C apps/app02/ test
	