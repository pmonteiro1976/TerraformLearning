resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
  tags = { 
    environment= "lab",
    deploy= "terraform",
    owner="Findmore Academy"
   }
}

resource "azurerm_virtual_network" "lab_vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.rg_name
  tags = { 
    environment= "lab",
    deploy= "terraform",
    owner="Findmore Academy"
   }

  address_space = [
    var.address_space
  ]
}