terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "3.0.2"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = local.subscription_id
}

provider "azuread" {
}

locals {
  subscription_id = "d8c00bed-c0a8-4ae2-ba65-dbd7fe1c5139"
}

data "azuread_client_config" "current" {}

resource "azuread_application" "capz" {
  display_name = "hmc-flux-capz"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "capz" {
  client_id                    = azuread_application.capz.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azurerm_role_assignment" "capz" {
  principal_id         = azuread_service_principal.capz.object_id
  principal_type       = "ServicePrincipal"
  role_definition_name = "Contributor"
  scope                = "/subscriptions/${local.subscription_id}"
}

resource "azuread_service_principal_password" "capz" {
  service_principal_id = azuread_service_principal.capz.id
}
