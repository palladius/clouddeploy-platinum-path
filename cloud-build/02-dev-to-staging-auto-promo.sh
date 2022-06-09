#!/bin/bash

# TODO
# once
echo TODO to be implemented yet. The idea is that something deployed to DEV triggers a second Cloud Build build which does the following:
echo 1. cd /apps/$MYAPP
echo 2. make test
echo 3. if good, approve from dev to STAGING.
# When this will work I'll need to create an app to applaude me and link thru go/applaude-ricc.