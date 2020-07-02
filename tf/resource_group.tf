locals {
  resource_group_name = format("%s_rg", local.prefix)
}

resource "azurerm_resource_group" "deploy" {
  name     = local.resource_group_name
  location = var.location
}