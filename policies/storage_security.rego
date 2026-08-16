package azure.governance

deny contains msg if {
  rc := input.resource_changes[_]
  rc.type == "azurerm_storage_account"
  rc.change.actions[_] != "delete"
  rc.change.after.min_tls_version != "TLS1_2"
  msg := sprintf("%s must enforce TLS 1.2", [rc.address])
}

deny contains msg if {
  rc := input.resource_changes[_]
  rc.type == "azurerm_storage_account"
  rc.change.actions[_] != "delete"
  rc.change.after.allow_nested_items_to_be_public == true
  msg := sprintf("%s must disable anonymous public blob access", [rc.address])
}

deny contains msg if {
  rc := input.resource_changes[_]
  rc.type == "azurerm_storage_account"
  rc.change.actions[_] != "delete"
  rc.change.after.public_network_access_enabled == true
  msg := sprintf("%s exposes public network access; use private connectivity", [rc.address])
}
