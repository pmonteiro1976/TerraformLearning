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

//recovering resources form lab 4

resource "random_string" "Keyvault_suffix" {
  length  = 6
  upper   = false
  special = false
}

data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "main" {
  name                      = "kv-${var.application_name}-${var.environment_name}-${random_string.Keyvault_suffix.result}"
  location                  = azurerm_resource_group.main.location
  resource_group_name       = azurerm_resource_group.main.name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = "standard"
  enable_rbac_authorization = true

}

resource "azurerm_role_assignment" "terraform_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}



//--------------------------------------------

resource "azurerm_public_ip" "vm1" {
  name                = "pip-${var.application_name}-${var.environment_name}-${local.region_code}-vm1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"


}

data "azurerm_subnet" "bravo" {
  name                 = "snet-bravo"
  virtual_network_name = "vnet-network-dev-wcde"
  resource_group_name  = "rg-network-dev-wcde-002"
}




resource "azurerm_network_interface" "vm1" {
  name                = "nic-${var.application_name}-${var.environment_name}-${local.region_code}-vm1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.default_tags

  ip_configuration {
    name                          = "public"
    subnet_id                     = data.azurerm_subnet.bravo.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1.id
  }
}

# RSA key of size 4096 bits
resource "tls_private_key" "vm1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "vm1${var.application_name}${var.environment_name}${local.region_code}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.default_tags
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.vm1.id,
  ]

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.vm1.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


resource "azurerm_virtual_machine_extension" "entra_id_login" {
  name                       = "${azurerm_linux_virtual_machine.vm1.name}-AADSSHLogin"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm1.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}


resource "azurerm_role_assignment" "entra_id_user_login" {
  scope                = azurerm_linux_virtual_machine.vm1.id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = azuread_group.trf_lab6_remote_access_users.object_id
}

/*replaced by key vault secrets
resource "local_file" "private_key" {
  content         = tls_private_key.vm1.private_key_pem
  filename        = pathexpand("~/.ssh/vm1")
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content         = tls_private_key.vm1.public_key_openssh
  filename        = pathexpand("~/.ssh/vm1.pub")
  file_permission = "0600"
}
*/
resource "azurerm_key_vault_secret" "vm1_ssh_private" {
  name         = "vm1-ssh-private"
  value        = tls_private_key.vm1.private_key_pem
  key_vault_id = azurerm_key_vault.main.id
  depends_on   = [azurerm_role_assignment.terraform_user]
}

resource "azurerm_key_vault_secret" "vm1_ssh_public" {
  name         = "vm1-ssh-public"
  value        = tls_private_key.vm1.public_key_pem
  key_vault_id = azurerm_key_vault.main.id
  depends_on   = [azurerm_role_assignment.terraform_user]
}

