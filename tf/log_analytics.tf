# Generate random text for a unique storage account name
resource "random_id" "oms_random" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.deploy.name
    index          = var.instance
  }
  byte_length = 8
}

locals {
  azurerm_log_analytics_workspace_name = format("%s-oms-%s", local.prefix, random_id.oms_random.hex)
}

resource "azurerm_log_analytics_workspace" "oms" {
  name                = local.azurerm_log_analytics_workspace_name
  location            = azurerm_resource_group.deploy.location
  resource_group_name = azurerm_resource_group.deploy.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
