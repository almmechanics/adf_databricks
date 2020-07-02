terraform {
  backend "azurerm" {}
}

module "tf" {
  source = "../tf"
}