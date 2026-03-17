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
  name     = "rg-${var.application_name}-${var.environment_name}-${local.region_code}-002"
  location = var.primary_location
  tags     = local.default_tags

}

resource "random_string" "Keyvault_suffix" {
    length = 6
    upper = false
    special = false
}

data "azurerm_client_config" "current"{}


resource "azurerm_key_vault" "main" {
  name                        = "kv-${var.application_name}-${var.environment_name}-${random_string.Keyvault_suffix.result}"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name = "standard"
  enable_rbac_authorization = true
  
}

resource "azurerm_role_assignment" "terraform_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}


data "azurerm_log_analytics_workspace" "observability" {
  name                = "log-analytics-focloud-test-wcde-001"
  resource_group_name = "rg-focloud-test-wcde-002"
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  name               = "Diag-${var.application_name}-${var.environment_name}-${random_string.Keyvault_suffix.result}"
  target_resource_id = azurerm_key_vault.main.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.observability.id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
  }
}