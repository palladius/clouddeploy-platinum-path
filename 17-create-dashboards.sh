#!/bin/bash

source .env.sh || _fatal 'Couldnt source this'
#set -x
set -e

PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')

	# to be tested yet, might have to change name of metric or dashboard to adapt.
	# 1. creates a metric called cli_statusz_count (see gcloud not filename which is coincidential)


bin/proceed_if_error_matches 'already exists' \
    gcloud logging metrics create cli_statusz_count --config-from-file var/metrics/cli_statusz_count

	# 2. create dashboard based on dashboard id (might have to change project number for different project)
	# like `cat var/dashboards/riccardo-canary-vs-prod.yaml | sed -i s/133380571425/$PROJECT_NUMBER/ | blah.."`" | tee t

# movint to temp file. Apologies for broken code.
cat var/dashboards/riccardo-canary-vs-prod.yaml |  sed -e "s/133380571425/$PROJECT_NUMBER/" > t
gcloud monitoring dashboards create --config-from-file t # var/dashboards/riccardo-canary-vs-prod.yaml
