
SHELL := /bin/bash

test:
	echo App03 Always OK.

skaffold-dev-dev:
	./skaffold-wrapper.sh dev -p dev

docker-build:
	docker build -t kunode .
docker-run:
	docker run -it kunode
run-dev:
	nodemon src/app.js
