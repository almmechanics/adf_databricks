variable "location" {
  description = "Common resource group to target"
  type        = string
}

variable "instance" {
  type = number
}

variable "prefix" {
  type = string
}

variable "vnet_cidr" {
  type        = string
  description = "VPC cidr block. Example: 10.10.0.0/16"
}

variable "log_retention_days" {
  type = number
}

variable "client_secret" {
  type = string
}

variable "client_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}