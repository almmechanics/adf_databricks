# Generate random text for a unique storage account name
resource "random_id" "kv_random" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.deploy.name
    index          = var.instance
  }
  byte_length = 4
}

locals {
  keyvault_name           = format("%skv%s", local.prefix, random_id.kv_random.hex)
  keyvault_oms_product    = "KeyVaultAnalytics"
  keyvault_analytics_name = format("%s(%s)", local.keyvault_oms_product, azurerm_log_analytics_workspace.oms.name)
}


resource "azurerm_key_vault" "keyvault" {
  name                        = local.keyvault_name
  location                    = azurerm_resource_group.deploy.location
  resource_group_name         = azurerm_resource_group.deploy.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled         = true
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "get", "list"
    ]

  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}


data "azurerm_monitor_diagnostic_categories" "kv" {
  resource_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_monitor_diagnostic_setting" "kv" {
  name                       = local.keyvault_name
  target_resource_id         = azurerm_key_vault.keyvault.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.oms.id


  dynamic "log" {
    iterator = log_category
    for_each = data.azurerm_monitor_diagnostic_categories.kv.logs

    content {
      category = log_category.value
      enabled  = true

      retention_policy {
        enabled = true
        days    = var.log_retention_days
      }
    }
  }

  dynamic "metric" {
    iterator = metric_category
    for_each = data.azurerm_monitor_diagnostic_categories.kv.metrics

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

resource "azurerm_template_deployment" "keyvault_analytics" {
  name                = local.keyvault_analytics_name
  resource_group_name = azurerm_resource_group.deploy.name
  template_body       = data.local_file.oms_analytics.content
  deployment_mode     = "Incremental"

  parameters = {
    Name        = local.keyvault_analytics_name
    WorkspaceId = azurerm_log_analytics_workspace.oms.id
    OMSProduct  = local.keyvault_oms_product
  }
}



