locals {
  pipip_name   = format("%spipbastion", local.prefix)
  bastion_host = format("%sbastion", local.prefix)
}


resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.deploy.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 11, 16)]
}

resource "azurerm_public_ip" "bastion" {
  name                = local.pipip_name
  location            = azurerm_resource_group.deploy.location
  resource_group_name = azurerm_resource_group.deploy.name
  allocation_method   = "Static"
  sku                 = "Standard"
}



data "azurerm_monitor_diagnostic_categories" "bastion_pip" {
  resource_id = azurerm_public_ip.bastion.id
}

resource "azurerm_monitor_diagnostic_setting" "bastion_pip" {
  name                       = local.keyvault_name
  target_resource_id         = azurerm_public_ip.bastion.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.oms.id


  dynamic "log" {
    iterator = log_category
    for_each = data.azurerm_monitor_diagnostic_categories.bastion_pip.logs

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
    for_each = data.azurerm_monitor_diagnostic_categories.bastion_pip.metrics

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




resource "azurerm_bastion_host" "bastion" {
  name                = local.bastion_host
  location            = azurerm_resource_group.deploy.location
  resource_group_name = azurerm_resource_group.deploy.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}


data "azurerm_monitor_diagnostic_categories" "bastion" {
  resource_id = azurerm_bastion_host.bastion.id
}

resource "azurerm_monitor_diagnostic_setting" "bastion" {
  name                       = local.keyvault_name
  target_resource_id         = azurerm_bastion_host.bastion.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.oms.id


  dynamic "log" {
    iterator = log_category
    for_each = data.azurerm_monitor_diagnostic_categories.bastion.logs

    content {
      category = log_category.value
      enabled  = true

      retention_policy {
        enabled = true
        days    = var.log_retention_days
      }
    }
  }
}