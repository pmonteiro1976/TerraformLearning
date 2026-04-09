locals {

  // automate/dynamic code subnet adresss space:
  //alpha_address_space   = cidrsubnet(var.base_address_space, 2, 0) deleted in lab6 for bastion creation purposes
  bastion_address_space = cidrsubnet(var.base_address_space, 4, 0)
  bravo_address_space   = cidrsubnet(var.base_address_space, 2, 1)
  charlie_address_space = cidrsubnet(var.base_address_space, 2, 2)
  delta_address_space   = cidrsubnet(var.base_address_space, 2, 3)

}

resource "azurerm_resource_group" "network" {
  name     = "rg-${var.application_name2}-${var.environment_name}-${local.region_code}-002"
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


resource "azurerm_virtual_network" "main" {

  name                = "vnet-${var.application_name2}-${var.environment_name}-${local.region_code}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = [var.base_address_space]

}



//10.40.0.0/24
/* removed on lab6
resource "azurerm_subnet" "alpha" {
  name                 = "snet-alpha"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.alpha_address_space]

}
*/

//10.40.0.0/26
// start at: 10.40.0.0
// end at : 10.40.0.63
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet" //determined name for bastion to work
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.bastion_address_space]

}

//10.40.1.0/24
resource "azurerm_subnet" "bravo" {
  name                 = "snet-bravo"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.bravo_address_space]

}
//10.40.2.0/24
resource "azurerm_subnet" "charlie" {
  name                 = "snet-charlie"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.charlie_address_space]

}
//10.40.3.0/24
resource "azurerm_subnet" "delta" {
  name                 = "snet-delta"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.delta_address_space]

}

// with bastion active this sg does not have meaning
/*
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
*/

/* remmoved on lab6
resource "azurerm_subnet_network_security_group_association" "alpha_remote_access" {
  subnet_id                 = azurerm_subnet.alpha.id
  network_security_group_id = azurerm_network_security_group.remote_access.id
}
*/

#dinamically get you public ip
data "http" "my_ip" {
  url = "https://ifconfig.me/ip"

}


//bastion config:
resource "azurerm_public_ip" "bastion" {
  name                = "pip-${var.application_name2}-${var.environment_name}-${local.region_code}-bastion"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "main" {
  name                = "bas-${var.application_name2}-${var.environment_name}-${local.region_code}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}