#!/bin/bash
set -e

ACTION=${1:-plan}  # default to plan if no argument


#Attention: bash script does is very sensible to white spaces
# Set the subscription
export ARM_SUBSCRIPTION_ID="1ac63b44-5fd9-4c8d-9f02-8e402430ed50"

# set the applucation / environment
export TF_VAR_application_name="focloud"
export TF_VAR_environment_name="test"

#set the backend config- CREATED ENV VARIABLES TO USE IN THE BACKEND CONFIGURATION
export BACKEND_RESOURCE_GROUP="rg-focloud-test-wcde-001"
export BACKEND_STORAGE_ACCOUNT="stfocloudtestwcde001"
export BACKEND_CONTAINER_NAME="tfstate"
export BACKEND_KEY="focloud.test.terraform.tfstate"

#Run terraform command
terraform init \
    -backend-config="resource_group_name=${BACKEND_RESOURCE_GROUP}" \
    -backend-config="storage_account_name=${BACKEND_STORAGE_ACCOUNT}" \
    -backend-config="container_name=${BACKEND_CONTAINER_NAME}" \
    -backend-config="key=${BACKEND_KEY}"

#terraform $*
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TFVARS_FILE="${SCRIPT_DIR}/test.tfvars"

terraform $ACTION -var-file="${TFVARS_FILE}"


#rm -rf .terraform
[[ "$ACTION" == "init" ]] && rm -rf .terraform