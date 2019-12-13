variable "ENVIRONMENT" {
  type    = string
  default = "dev"
}

variable "NODE_COUNT" {
  type    = string
  default = "1"
}

variable "VM_SIZE" {
  type    = string
  default = "Standard_B2s"
}

variable "LOCATION" {
  type = string
  default = "northeurope"
}

variable "K8S_VERSION" {
  type = string
  default = "1.14.8"
}

locals {
  prefix  = "${var.ENVIRONMENT}${local.project}"
  project = "core"
}

resource "azurerm_resource_group" "core" {
  name     = local.prefix
  location = var.LOCATION
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${local.prefix}aks"
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  dns_prefix          = "${local.prefix}aks"
  kubernetes_version  = var.K8S_VERSION

  default_node_pool {
    name       = "default"
    node_count = var.NODE_COUNT
    vm_size    = var.VM_SIZE
  }

  service_principal {
    client_id     = azuread_application.aks.application_id
    client_secret = azuread_service_principal_password.aks.value
  }

  addon_profile {
    kube_dashboard {
      enabled = true
    }
  }


  tags = {
    Environment = var.ENVIRONMENT
    Project     = local.project
  }
}

resource "azuread_application" "aks" {
  name                       = "${local.prefix}aks"
  homepage                   = "https://homepage"
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = false
}

resource "azuread_service_principal" "aks" {
  application_id               = azuread_application.aks.application_id
  app_role_assignment_required = false
}

resource "azuread_service_principal_password" "aks" {
  service_principal_id = azuread_service_principal.aks.id
  value                = random_string.password.result
  end_date             = "2030-01-01T01:02:03Z"
}

resource "random_string" "password" {
  length  = 32
  special = true
}