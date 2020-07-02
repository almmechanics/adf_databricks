# Generate random text for a unique storage account name
resource "random_id" "adf_random" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.deploy.name
    index          = var.instance
  }
  byte_length = 8
}

locals {
  azurerm_data_factory_name = format("%sadf%s", local.prefix, random_id.adf_random.hex)
  adf_oms_product           = "AzureDataFactoryAnalytics"
  adf_analytics_name        = format("%s(%s)", local.adf_oms_product, azurerm_log_analytics_workspace.oms.name)
}


resource "azurerm_data_factory" "adf" {
  name                = local.azurerm_data_factory_name
  location            = azurerm_resource_group.deploy.location
  resource_group_name = azurerm_resource_group.deploy.name
}


resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "storage" {
  name                  = "sharedstorage"
  resource_group_name   = azurerm_resource_group.deploy.name
  data_factory_name     = local.azurerm_data_factory_name
  service_principal_id  = data.azurerm_client_config.current.client_id
  service_principal_key = "exampleKey"
  tenant                = data.azurerm_client_config.current.tenant_id
  url                   = module.data_storage.primary_blob_endpoint
}



## Diagnostis
data "azurerm_monitor_diagnostic_categories" "adf" {
  resource_id = azurerm_data_factory.adf.id
}

resource "azurerm_monitor_diagnostic_setting" "adf" {
  name                       = local.azurerm_data_factory_name
  target_resource_id         = azurerm_data_factory.adf.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.oms.id


  dynamic "log" {
    iterator = log_category
    for_each = data.azurerm_monitor_diagnostic_categories.adf.logs

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
    for_each = data.azurerm_monitor_diagnostic_categories.adf.metrics

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


resource "azurerm_template_deployment" "adf_analytics" {
  name                = local.adf_analytics_name
  resource_group_name = azurerm_resource_group.deploy.name
  template_body       = data.local_file.oms_analytics.content
  deployment_mode     = "Incremental"

  parameters = {
    Name        = local.adf_analytics_name
    WorkspaceId = azurerm_log_analytics_workspace.oms.id
    OMSProduct  = local.adf_oms_product
  }
}


