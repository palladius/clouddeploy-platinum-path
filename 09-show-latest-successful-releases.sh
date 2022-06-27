#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal "Config doesnt exist please create .env.sh"
#set -x
#set -e

PIPELINE="${1:-dunno}"
VERBOSE=false
AUTO_PROMOTE_DEV_TO_STAGING=true

if echo $PIPELINE | grep -q dunno ; then 
    echo Give me app-01 or app02 in ARGV1 or for both just call: make show-latest-succesful-releases
    exit 42
fi

# Add your code here:
azure 10. INSPECTING CD PIPELINE="$PIPELINE"
echodo gcloud deploy releases list --delivery-pipeline "$PIPELINE" --filter renderState=SUCCEEDED \
    --format="table[box,title='Ricc Successful Releases for $PIPELINE'](createTime:sort=1, name:label=LongBoringName, renderState, skaffoldVersion, skaffoldConfigPath)" \
    --sort-by=~createTime 
#    --format yaml # 'multi(targetRenders.*.renderingState)'

# this teaches how to sort subfields iwthin an item not how to sort items. https://stackoverflow.com/questions/69527048/trying-to-reverse-the-sequence-of-values-returned-by-my-gcloud-query 
# useless here
#echodo gcloud deploy releases list --delivery-pipeline "$RELEASE" --filter renderState=SUCCEEDED \
#    --format="value(createTime, name)" --sort-by=createTime 
# A field to sort by, if applicable. To perform a descending-order sort, prefix the value with a tilde ("~").
# https://cloud.google.com/compute/docs/gcloud-compute/tips
# BINGO!

yellow 20. Lets now print out just the release name.. 
#echodo gcloud deploy releases list --delivery-pipeline app02 --filter renderState=SUCCEEDED  # --format 'multi(targetRenders.canary.renderingState)'
# gcloud deploy releases list --delivery-pipeline "$PIPELINE" --filter renderState=SUCCEEDED \
#    --format="value(name.split.7)"

# this gets the last release, eg 'projects/cicd-platinum-test001/locations/europe-west1/deliveryPipelines/app02/releases/app02-20220603-1621'
# then gcloud tokenizes it into semicolons, ive tried hard to do name.split()[7] but didnt work and couldnt find gcloud documentation on other functions like split.
LATEST_SUCCESSFUL_RELEASE=$(
    gcloud deploy releases list --delivery-pipeline "$PIPELINE" --filter renderState=SUCCEEDED \
    --format="value(name.split())" \
    --sort-by=~createTime --limit 1 |
    cut -d';' -f 8
    )
# I care about:
# 1. createTime: '2022-06-03T16:21:20.718745Z'
echo "the LATEST_SUCCESSFUL_RELEASE for this PIPELINE $PIPELINE is: '$LATEST_SUCCESSFUL_RELEASE' !!"

if $VERBOSE ; then 
    echodo gcloud deploy releases list --delivery-pipeline "$PIPELINE" --filter renderState=SUCCEEDED
fi 


#fatal 42 Debugging it..



# End of your code here
echo Everything is ok.