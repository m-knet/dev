terraform {
  required_version = "~> 0.12"
  required_providers {
    azurerm = "~> 1.41"
  }
}

variable "PREFIX" {
  type    = string
  default = "mk"
}

variable "ENVIRONMENT" {
  type    = string
  default = ""
}

variable "LOCATION" {
  type = string
  default = "northeurope"
}

locals {
  prefix  = "${var.PREFIX}${var.ENVIRONMENT}${local.project}"
  project = "core"
}

resource "azurerm_resource_group" "core" {
  name     = local.prefix
  location = var.LOCATION
}

output resource_group_name {
  value = azurerm_resource_group.core.name
}