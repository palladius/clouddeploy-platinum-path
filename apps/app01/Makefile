

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
	skaffold dev -p prod    --no-prune=false --cache-artifacts=false

test:
	echo App01 Always OK.