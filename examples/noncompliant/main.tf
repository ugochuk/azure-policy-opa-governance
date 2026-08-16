terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Intentionally insecure example used to demonstrate policy failures.
resource "azurerm_resource_group" "example" {
  name     = "rg-policy-noncompliant"
  location = "eastus2"
}

resource "azurerm_storage_account" "example" {
  name                            = "stpolicynoncompliant01"
  resource_group_name             = azurerm_resource_group.example.name
  location                        = azurerm_resource_group.example.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_0"
  allow_nested_items_to_be_public = true
  public_network_access_enabled   = true
}
