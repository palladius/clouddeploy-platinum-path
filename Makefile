
README:
	cat Makefile

status:
	bash 04-status.sh

def:
	echo Only works after step 4..
	skaffold dev
# build:
# 	skaffold build --module=app01
# 	skaffold build

cloud-build-locally:
	./06-cloud-build-locally.sh

build: cloud-build-locally
