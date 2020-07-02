data "azurerm_resource_group" "deploy" {
  name = var.resource_group_name
}

data "azurerm_log_analytics_workspace" "oms" {
  name                = var.azurerm_log_analytics_workspace_name
  resource_group_name = data.azurerm_resource_group.deploy.name
}


# Create storage account for  storage
resource "azurerm_storage_account" "storage" {
  name                     = var.name
  resource_group_name      = data.azurerm_resource_group.deploy.name
  location                 = data.azurerm_resource_group.deploy.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = var.is_hns_enabled
}


data "azurerm_monitor_diagnostic_categories" "storage" {
  resource_id = azurerm_storage_account.storage.id
}

resource "azurerm_monitor_diagnostic_setting" "storage" {
  name                       = var.name
  target_resource_id         = azurerm_storage_account.storage.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.oms.id

  dynamic "metric" {
    iterator = metric_category
    for_each = data.azurerm_monitor_diagnostic_categories.storage.metrics

    content {
      category = metric_category.value
      enabled  = true

      retention_policy {
        enabled = true
        days    = var.log_retention_days
      }
    }
  }
}