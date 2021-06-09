

terraform {
  required_version = ">= 0.11"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "1.1.1"
    }
  }
}

provider "azurerm" {
  features {}
}
provider "azuread" {
}

resource "azurerm_resource_group" "example" {
  name     = var.name
  location = var.location
}

data "azurerm_client_config" "main" {}



resource "azuread_application" "sp_api" {
  name                       = "anish_tf_api1"
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = false
  type                       = "webapp/api"
  identifier_uris            = ["api://anish_tf_apidemo12"]

  app_role {
    allowed_member_types = ["User", "Application"]
    description          = "Admins can manage roles and perform all task actions"
    display_name         = "Admin"
    is_enabled           = true
    value                = "admin"
  }
}

resource "azuread_application_oauth2_permission" "sp_apis_read_scope" {
  application_object_id      = azuread_application.sp_api.id
  admin_consent_description  = "Allow the application to grant read access"
  admin_consent_display_name = "sp.read"
  is_enabled                 = true
  type                       = "Admin"
  value                      = "sp.read"
  user_consent_description   = "Allow the application to grant read access"
  user_consent_display_name  = "sp.read"
}

resource "azuread_application_app_role" "sp_api_admin_approle" {
  application_object_id = azuread_application.sp_api.id
  allowed_member_types  = ["User", "Application"]
  description           = "Can read sp"
  display_name          = "AnishAdmin"
  is_enabled            = true
  value                 = "AnishAdmin"
}

resource "azurerm_app_service_plan" "example" {
  name                = "example-appserviceplan9898"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "example-app-service92837493287"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id
  https_only          = false



  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  auth_settings {
    enabled = true

    active_directory {
      client_id = azuread_application.sp_api.application_id
    }
  }
}
