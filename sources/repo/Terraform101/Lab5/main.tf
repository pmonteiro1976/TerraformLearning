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

  // automate/dynamic code subnet adresss space:
  alpha_address_space   = cidrsubnet(var.base_address_space, 2, 0)
  bravo_address_space   = cidrsubnet(var.base_address_space, 2, 1)
  charlie_address_space = cidrsubnet(var.base_address_space, 2, 2)
  delta_address_space   = cidrsubnet(var.base_address_space, 2, 3)

}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.application_name}-${var.environment_name}-${local.region_code}-002"
  location = var.primary_location
  tags     = local.default_tags

}

/*
resource "random_string" "Keyvault_suffix" {
length = 6
upper = false
special = false
}
*/

data "azurerm_client_config" "current" {}

resource "azurerm_virtual_network" "main" {

  name                = "vnet-${var.application_name}-${var.environment_name}-${local.region_code}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.base_address_space]

}



//10.39.0.0/24
resource "azurerm_subnet" "alpha" {
  name                 = "snet-alpha"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.alpha_address_space]

}
//10.39.1.0/24
resource "azurerm_subnet" "bravo" {
  name                 = "snet-bravo"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.bravo_address_space]

}
//10.39.2.0/24
resource "azurerm_subnet" "charlie" {
  name                 = "snet-charlie"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.charlie_address_space]

}
//10.39.3.0/24
resource "azurerm_subnet" "delta" {
  name                 = "snet-delta"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.delta_address_space]

}


resource "azurerm_network_security_group" "remote_access" {
  name                = "nsg-${var.application_name}-${var.environment_name}-${local.region_code}-remote-access"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = chomp(data.http.my_ip.response_body)
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet_network_security_group_association" "alpha_remote_access" {
  subnet_id                 = azurerm_subnet.alpha.id
  network_security_group_id = azurerm_network_security_group.remote_access.id
}

#dinamically get you public ip
data "http" "my_ip" {
  url = "https://ifconfig.me/ip"

}