variable "location" {
  description = "Common resource group to target"
  type        = string
  default     = "centralus"
}

variable "instance" {
  type    = number
  default = 7
}

variable "prefix" {
  type    = string
  default = "test"
}

variable "vnet_cidr" {
  type        = string
  description = "VPC cidr block. Example: 10.10.0.0/16"
  default     = "10.0.0.0/16"
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "client_secret" {
  type    = string
  default = "Invalid"
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