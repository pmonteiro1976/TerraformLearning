# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.8.0"
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
    resource_group_name  = "rg-focloud-test-wcde-001"
    storage_account_name = "stfocloudtestwcde001"
    container_name       = "tfstate"
    key                  = "lab6-linuxvm-dev"
    use_azuread_auth     = true
  }

}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "1ac63b44-5fd9-4c8d-9f02-8e402430ed50"
}
