
README:
	cat Makefile

status:
	@echo TODO kubectl get pods (TODO first add correct context)

build:
	skaffold build --module=app01
	skaffold build
