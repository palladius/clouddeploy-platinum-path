

dev:
	./skaffold-wrapper.sh dev

skaffold-dev-dev:
	./skaffold-wrapper.sh dev -p dev

skaffold-dev-canary:
	./skaffold-wrapper.sh dev -p canary

test-profiles:
	skaffold dev -p dev     --no-prune=false --cache-artifacts=false
	skaffold dev -p staging --no-prune=false --cache-artifacts=false
	skaffold dev -p canary  --no-prune=false --cache-artifacts=false
	skaffold dev -p production  --no-prune=false --cache-artifacts=false

test:
	echo App01 Always OK.

# ionly useful for local development
# from: https://developers.google.com/earth-engine/guides/python_install-conda#install_conda
install-conda:
	wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
	bash ~/miniconda.sh -b -p
	rm ~/miniconda.sh
	source $HOME/miniconda3/bin/activate
	conda --help



run-p8080:
	conda create --name cicd-app01-python
	conda activate cicd-app01-python
	conda install pip
	python3 -m pip install --requirement requirements.txt
#	conda install --file requirements.txt
	FLASK_APP=web.py python3 -m flask run --host=0.0.0.0 --port=8080

kustomize-dump:
	# safely git-ignored ;)
	mkdir -p tmp/
	kustomize build k8s/overlays/dev/    > tmp/tmp-dev.yaml
	kustomize build k8s/overlays/staging/> tmp/tmp-staging.yaml
	kustomize build k8s/overlays/canary/ > tmp/tmp-canary.yaml
	kustomize build k8s/overlays/production/   > tmp/tmp-prod.yaml
	diff tmp/tmp-prod.yaml tmp/tmp-canary.yaml

docker-run:
	docker run -it -p 8080:8080 app02-kuruby
