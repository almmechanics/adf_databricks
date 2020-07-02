locals {
  storage_name    = format("%sstorage", local.prefix)
  storage_landing = "landing"
  storage_shared  = "shared"
}

module "data_storage" {
  source                               = "./module_storage"
  name                                 = local.storage_name
  resource_group_name                  = azurerm_resource_group.deploy.name
  azurerm_log_analytics_workspace_name = azurerm_log_analytics_workspace.oms.name
  is_hns_enabled                       = true
  log_retention_days                   = var.log_retention_days
}

resource "azurerm_storage_container" "landing" {
  name                  = local.storage_landing
  storage_account_name  = local.storage_name
  container_access_type = "private"
}

resource "azurerm_storage_container" "shared" {
  name                  = local.storage_shared
  storage_account_name  = local.storage_name
  container_access_type = "private"
}