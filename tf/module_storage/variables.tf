variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "azurerm_log_analytics_workspace_name" {
  type = string
}

variable "is_hns_enabled" {
  type = bool
}

variable "log_retention_days" {
  type = number
}