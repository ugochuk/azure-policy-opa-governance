package azure.governance

deny contains msg if {
  rc := input.resource_changes[_]
  rc.type == "azurerm_key_vault"
  rc.change.actions[_] != "delete"
  rc.change.after.public_network_access_enabled == true
  msg := sprintf("%s must disable public network access", [rc.address])
}

deny contains msg if {
  rc := input.resource_changes[_]
  rc.type == "azurerm_key_vault"
  rc.change.actions[_] != "delete"
  rc.change.after.enable_rbac_authorization != true
  msg := sprintf("%s must use Azure RBAC authorization", [rc.address])
}

deny contains msg if {
  rc := input.resource_changes[_]
  rc.type == "azurerm_key_vault"
  rc.change.actions[_] != "delete"
  rc.change.after.purge_protection_enabled != true
  msg := sprintf("%s must enable purge protection", [rc.address])
}
