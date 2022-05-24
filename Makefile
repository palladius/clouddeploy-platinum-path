
README:
	cat Makefile

status:
	bash 04-status.sh

build:
	skaffold build --module=app01
	skaffold build
