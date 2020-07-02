locals {
  hub_name = format("%shub", local.prefix)
}

resource "azurerm_virtual_network" "hub" {
  name                = local.hub_name
  location            = azurerm_resource_group.deploy.location
  resource_group_name = azurerm_resource_group.deploy.name
  address_space       = [var.vnet_cidr]

}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.deploy.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 1)]
}
