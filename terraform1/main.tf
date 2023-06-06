terraform {
  required_version = ">= 0.11" 
backend "azurerm" {
    resource_group_name  = "rg-cenkay-0004-prod"
    storage_account_name = "cenkaysa"
    container_name       = "infra1"
    key                  = "terraform.tfstate"
}
	}

provider "azurerm" {
  features {}
}
variable "rg_name" {
default = "#{rg_name}#"
}
variable "location" {
    default = "#{location}#"
}
variable "aml_workspace"{
    default = "#{aml_workspace}#"
}
variable "tenant_id"{
    default = "#{tenant_id}#"
}

resource "azurerm_resource_group" "infra1" {
  name     = var.rg_name
  location = var.location
}
data "azurerm_client_config" "current" {}

resource "azurerm_application_insights" "infra2" {
  name                = "mlops-cenkay-appinsight"
  location            = azurerm_resource_group.infra1.location
  resource_group_name = azurerm_resource_group.infra1.name
  application_type    = "web"
}

resource "azurerm_key_vault" "infra3" {
  name                = "mlops-cenkay-kv"
  location            = azurerm_resource_group.infra1.location
  resource_group_name = azurerm_resource_group.infra1.name
  tenant_id           = var.tenant_id
  sku_name            = "standard"
}

resource "azurerm_storage_account" "infra4" {
  name                     = "mlopscenkaysa"
  location                 = azurerm_resource_group.infra1.location
  resource_group_name      = azurerm_resource_group.infra1.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
}
resource "azurerm_machine_learning_workspace" "infra5" {
  name                    = var.aml_workspace
  location                = azurerm_resource_group.infra1.location
  resource_group_name     = azurerm_resource_group.infra1.name
  application_insights_id = azurerm_application_insights.infra2.id
  key_vault_id            = azurerm_key_vault.infra3.id
  storage_account_id      = azurerm_storage_account.infra4.id
  identity {
    type = "SystemAssigned"
  }
  }
  