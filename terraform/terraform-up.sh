
source ../.env.sh || fatal 'Couldnt source this'
set -x
set -e

echo "PROJECT_ID: $PROJECT_ID" 

# if [ -f .terraform/ ] ; then
#     echo Terraform folder found. Skipping init.
# else
#     terraform init 
# fi 

set -x

# https://www.terraform.io/cli/config/environment-variables
export TF_VAR_project_id="$PROJECT_ID"
export TF_VAR_gcp_region="$CLOUD_DEPLOY_REGION"
# To create this key, check code in `./13-create-Svc-Account-for-Terraform.sh`, its quite straightforward.
export TF_VAR_gcp_credentials_json='../private/tf-cd-sa.key'

TF_OPTS="-no-color -auto-approve -var foo=bar"
TF_VAR_region="$REGION" /usr/local/bin/terraform apply -auto-approve 
