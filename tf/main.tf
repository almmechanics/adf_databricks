provider "azurerm" {
  version                    = "=2.14.0"
  skip_provider_registration = true
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

provider "local" {}

locals {
  prefix = format("%s%03d", var.prefix, var.instance)
}

data "azurerm_client_config" "current" {}

data "local_file" "oms_analytics" {
  filename = "${path.module}/arm/oms_analytics.json"
}
