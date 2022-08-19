#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal "Config doesnt exist please create .env.sh"
#set -x
set -e

#######################################################################
# This script requires some manual config for the script which I'm working
# on ATM and will add to README.md when ready. Simply put, you need to
# have any GCR repo with `/apps/app01/` and `/apps/app02/` code.
#
#
# Internal ref: b/170325147
#######################################################################



# Add your code here:

# array: https://stackoverflow.com/questions/12317483/array-of-arrays-in-bash
# TeamNumber ; TeamName ; CloudBuild file ; Source To Be listening
TEAMS[0]='T1py;app01;cloudbuild.yaml;apps/app01/;green'
TEAMS[1]='T2rb;app02;cloudbuild.yaml;apps/app02/;red'
#TEAMS[2]='T3;frontend;cloudbuild-super-parametric.yaml;src/frontend/;yellow'
#TEAMS[3]='T4;loadgenerator;cloudbuild-super-parametric.yaml;src/loadgenerator/;red'

TRIGGERVERSION="1-7"
# 1.7  20220708 Changed colors cos Ruby is Red and Python is green, but more importantly I dont want to confuse people with blue/green deployment since app_id is orthogonal to deployment stage.
# 1.6  20220610 Added 'cloud-build/**' to trigger changes.
# 1.5b 20220603 I didnt change a thing but DESTROYED everything since i had 4 triggers, 2 in 1.5a and 2 in 1.3 so wanted to have a clean slate.
# 1.5a          ????
# 1.4           Added DEPLOY_REGION as per CD necessity.
# 1.3           Made from regional to GLOBAL (local have QUOTA issues) #important
# 1.2           Made better substitutions.
touch /tmp/MyEmptyFile

GITHUB_REPO_NAME="clouddeploy-platinum-path"
GCR_REPO="${GITHUB_REPO_OWNER}/clouddeploy-platinum-path"

yellow "*** WARNING ***"
yellow "  To run this script you need to have enabled the 6.5 docs in the README.md"
yellow "  Also you need to have set up your GITHUB_REPO_OWNER='$GITHUB_REPO_OWNER' (if this an empty string, this ain't gonna work)"
yellow "*** END ***"
echo

for TEAM_ARR in "${TEAMS[@]}"; do
    IFS=";" read -r -a arr <<< "${TEAM_ARR}"

    TEAM_NUMBER="${arr[0]}"
    TEAM_NAME="${arr[1]}"
    BUILD_FILE="${arr[2]}"
    SRC_SUBFOLDER="${arr[3]}"
    FAV_COLOR="${arr[4]}"

    #gray $TEAMS
    gsutil cp /tmp/MyEmptyFile gs://$SKAFFOLD_BUCKET/skaffold-cache/$TEAM_NAME.txt

    SUBSTITUTIONS="_DEPLOY_UNIT=$TEAM_NAME,_REGION=$REGION,_ARTIFACT_REPONAME=$ARTIFACT_REPONAME,_DEPLOY_REGION=$CLOUD_DEPLOY_REGION"

    set -x
    # This sets up on GCR
    proceed_if_error_matches 'generic::already_exists: trigger' \
      gcloud alpha builds triggers create github --repo-owner="$GITHUB_REPO_OWNER" --repo-name="$GITHUB_REPO_NAME" --branch-pattern='.*' \
      --description="[$TEAM_NUMBER] CB trigger from CLI for $TEAM_NAME module" --included-files="${SRC_SUBFOLDER}**,*.yaml,cloud-build/**" \
      --build-config cloudbuild.yaml --substitutions="$SUBSTITUTIONS" \
      --name "$TEAM_NUMBER-CLIv$TRIGGERVERSION-$TEAM_NAME"

    # Important note: bYou might want to add "" --region "$REGION" "" which was needed for some.
    # * Nate (US) had to add it it or it wouldnt work.
    # * Ricc (EU) added it and it wouldnt work WITH, only without.
    # I'm unable to explain this difference unless US and EMEA regions are not equal

    # If you choose to connect to GCR, use this comand instead (note: might be a bit old and not updated like the one above #metafishing ).

    # echo NOT_THIS gcloud alpha builds triggers create cloud-source-repositories \
    #   --repo=$GITHUB_REPO_OWNER/clouddeploy-platinum-path --branch-pattern='.*' \
    #   --description="[$TEAM_NUMBER] CB trigger from CLI for $TEAM_NAME module" --included-files="${SRC_SUBFOLDER}**,*.yaml" \
    #   --build-config cloudbuild.yaml --substitutions="_DEPLOY_UNIT=$TEAM_NAME,_FAVORITE_COLOR=$FAV_COLOR" \
    #   --region=$REGION --name $TEAM_NUMBER-CLIv$TRIGGERVERSION-$TEAM_NAME

done

# some self gratification :)
echo Here are the triggers:
gcloud alpha builds triggers list --format 'table(name,github.owner,github.user,github.name,description,includedFiles)'

# End of your code here
_allgood_post_script
echo Everything is ok.
