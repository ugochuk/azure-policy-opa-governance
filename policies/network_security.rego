package azure.governance

deny contains msg if {
  rc := input.resource_changes[_]
  rc.type == "azurerm_network_security_rule"
  rc.change.actions[_] != "delete"
  lower(rc.change.after.access) == "allow"
  rc.change.after.source_address_prefix == "*"
  contains(rc.change.after.destination_port_range, "22")
  msg := sprintf("%s allows unrestricted SSH access", [rc.address])
}

deny contains msg if {
  rc := input.resource_changes[_]
  rc.type == "azurerm_network_security_rule"
  rc.change.actions[_] != "delete"
  lower(rc.change.after.access) == "allow"
  rc.change.after.source_address_prefix == "*"
  contains(rc.change.after.destination_port_range, "3389")
  msg := sprintf("%s allows unrestricted RDP access", [rc.address])
}
