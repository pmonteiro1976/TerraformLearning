//introduced in lab azuread provider
data "azuread_client_config" "current" {}

data "azuread_user" "remote_access_users" {
  //count               = length(var.remote_access_users)
  //user_principal_name = var.remote_access_users[count.index]
  for_each            = local.remote_access_users_map
  user_principal_name = each.key
}

resource "azuread_group" "trf_lab6_remote_access_users" {
  display_name     = "${var.application_name}-${var.environment_name}-remote-access-users"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}

// so one can use the for loop
locals {
  remote_access_users_map = { for idx, element in var.remote_access_users : element => idx }
}

//removing the unstable reference of data "azuread_client_config" "current"
resource "azuread_group_member" "remote_access_users_membership" {
  //count            = length(var.remote_access_users)
  for_each        = local.remote_access_users_map
  group_object_id = azuread_group.trf_lab6_remote_access_users.object_id
  //member_object_id = data.azuread_user.remote_access_users[count.index].object_id
  member_object_id = data.azuread_user.remote_access_users[each.key].object_id
}

