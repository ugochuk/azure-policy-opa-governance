package azure.governance

deny contains msg if {
  rc := input.resource_changes[_]
  rc.change.actions[_] != "delete"
  not rc.change.after.tags.Environment
  msg := sprintf("%s is missing required Environment tag", [rc.address])
}
