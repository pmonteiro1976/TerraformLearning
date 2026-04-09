# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.8.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.2.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }

    random = {

      source  = "hashicorp/random"
      version = "~> 3.6.3"

    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-focloud-dev-wcde-001"
    storage_account_name = "stfoclouddevwcde001"
    container_name       = "tfstatedev"
    key                  = "lab6-linuxvm-dev"
    use_azuread_auth     = true
  }

}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted_secrets = true
    }

  }
  subscription_id = "1ac63b44-5fd9-4c8d-9f02-8e402430ed50"
}
