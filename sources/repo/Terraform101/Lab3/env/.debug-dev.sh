#!/bin/bash
set -e

ACTION=${1:-plan}  # default to plan if no argument

#Attention: bash script does is very sensible to white spaces
# Set the subscription
az account set --subscription "1ac63b44-5fd9-4c8d-9f02-8e402430ed50"



# Set the subscription
export ARM_SUBSCRIPTION_ID="1ac63b44-5fd9-4c8d-9f02-8e402430ed50"

# set the applucation / environment
export TF_VAR_application_name="focloud"
export TF_VAR_environment_name="dev"

#set the backend config- CREATED ENV VARIABLES TO USE IN THE BACKEND CONFIGURATION
export BACKEND_RESOURCE_GROUP="rg-focloud-dev-wcde-001"
export BACKEND_STORAGE_ACCOUNT="stfoclouddevwcde001"
export BACKEND_CONTAINER_NAME="tfstatedev"
export BACKEND_KEY="focloud.dev.terraform.tfstate"


# Create backend resource group if it doesn't exist
if ! az group show --name "$BACKEND_RESOURCE_GROUP" &>/dev/null; then
  az group create --name "$BACKEND_RESOURCE_GROUP" --location "Germany West Central"
fi


# Create storage account if it doesn't exist
if ! az storage account show --name "$BACKEND_STORAGE_ACCOUNT" --resource-group "$BACKEND_RESOURCE_GROUP" &>/dev/null; then
  az storage account create \
    --name "$BACKEND_STORAGE_ACCOUNT" \
    --resource-group "$BACKEND_RESOURCE_GROUP" \
    --location "Germany West Central" \
    --sku Standard_LRS \
    --kind StorageV2
fi


# Create container if it doesn't exist
if ! az storage container show --name "$BACKEND_CONTAINER_NAME" --account-name "$BACKEND_STORAGE_ACCOUNT" &>/dev/null; then
  az storage container create \
    --name "$BACKEND_CONTAINER_NAME" \
    --account-name "$BACKEND_STORAGE_ACCOUNT"
fi


#Run terraform command
terraform init \
    -backend-config="resource_group_name=${BACKEND_RESOURCE_GROUP}" \
    -backend-config="storage_account_name=${BACKEND_STORAGE_ACCOUNT}" \
    -backend-config="container_name=${BACKEND_CONTAINER_NAME}" \
    -backend-config="key=${BACKEND_KEY}"

#terraform $*
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TFVARS_FILE="${SCRIPT_DIR}/dev.tfvars"

terraform $ACTION -var-file="${TFVARS_FILE}"

[[ "$ACTION" == "init" ]] && rm -rf .terraform
