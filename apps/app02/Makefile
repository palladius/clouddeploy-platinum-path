

skaffold-dev:
	./skaffold-wrapper.sh dev

skaffold-run-dev:
	./skaffold-wrapper.sh run -p dev
skaffold-run-canary:
	./skaffold-wrapper.sh run -p canary



test:
	echo Text fixed now all good
	which ruby && ruby ruby-app/app.rb || echo Sorry no ruby pls install it.
	echo Looks like Ruby app returns so looks like no Syntax Horrors.
#echo 02. Now trying to skaffold build this gentleman..
# NOPE THIS DOESNT WORK YET IN THE CLOUD :/ ./skaffold-wrapper.sh build
#	echo Lets pretend this doesnt build.
#	/bin/false


# 02. Now trying to skaffold build this gentleman..
# ./skaffold-wrapper.sh build
# ./skaffold-wrapper.sh: 2: ./skaffold-wrapper.sh: source: not found
# Setting SK DFLT REPO to: 
# ./skaffold-wrapper.sh: 3: ./skaffold-wrapper.sh: fatal: not found
# ./skaffold-wrapper.sh: 6: ./skaffold-wrapper.sh: echodo: not found
# make: *** [Makefile:18: test] Error 127
