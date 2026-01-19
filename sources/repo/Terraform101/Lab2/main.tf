
locals {
  default_tags = {
    created_by   = "terraform"
    owner        = "paulo.monteiro@simplify-hospitality.com"
    env          = var.environment_name
    Product      = var.application_name
    Creationdate = formatdate("YYYY-MM-DD", timestamp())
  }

  region_code_map = {
    "Germany West Central" = "wcde"
    "West Europe"          = "we"
    "North Europe"         = "ne"
    "East US"              = "eus"
    "West US"              = "wus"
    # Add more as needed
  }

  region_code = lookup(local.region_code_map, var.primary_location, "unknown")

}



resource "azurerm_resource_group" "main" {
  name     = "rg-${var.application_name}-${var.environment_name}-${local.region_code}-001"
  location = var.primary_location
  tags     = local.default_tags

}

resource "azurerm_storage_account" "main" {
  name                     = "st${var.application_name}${var.environment_name}${local.region_code}001"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.default_tags

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}
