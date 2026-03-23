resource "azurerm_container_registry" "acr" {
  name                = var.registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = true
}

resource "azurerm_container_group" "container" {
  name                = var.container_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = var.os_type

  container {
    name   = "hello-container"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld"
    cpu    = "0.5"
    memory = "1.0"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  ip_address_type = "Public"
  dns_name_label  = var.dns_label
}