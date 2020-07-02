terraform {
  backend "local" {}
}

module "tf" {
  source             = "../tf"
  location           = var.location
  instance           = var.instance
  prefix             = var.prefix
  vnet_cidr          = var.vnet_cidr
  log_retention_days = var.log_retention_days
  client_secret      = var.client_secret
  client_id          = var.client_id
  tenant_id          = var.tenant_id
  subscription_id    = var.subscription_id
}
