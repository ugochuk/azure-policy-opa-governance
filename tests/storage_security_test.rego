package azure.governance

import data.azure.governance.deny

test_secure_storage_has_no_denials if {
  result := deny with input as {
    "resource_changes": [{
      "address": "azurerm_storage_account.secure",
      "type": "azurerm_storage_account",
      "change": {
        "actions": ["create"],
        "after": {
          "tags": {"Environment": "prod"},
          "min_tls_version": "TLS1_2",
          "allow_nested_items_to_be_public": false,
          "public_network_access_enabled": false
        }
      }
    }]
  }
  count(result) == 0
}

test_insecure_storage_is_denied if {
  result := deny with input as {
    "resource_changes": [{
      "address": "azurerm_storage_account.insecure",
      "type": "azurerm_storage_account",
      "change": {
        "actions": ["create"],
        "after": {
          "tags": {"Environment": "dev"},
          "min_tls_version": "TLS1_0",
          "allow_nested_items_to_be_public": true,
          "public_network_access_enabled": true
        }
      }
    }]
  }
  count(result) == 3
}
