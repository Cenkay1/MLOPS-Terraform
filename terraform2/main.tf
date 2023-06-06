 terraform {
  required_version = ">= 0.11" 
backend "azurerm" {
    resource_group_name  = "rg-cenkay-0004-prod"
    storage_account_name = "cenkaysa"
    container_name       = "infra2"
    key                  = "terraform2.tfstate"
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
variable "workspace_name"{
    default = "#{aml_workspace}#"
}
variable "tenant_id"{
    default = "#{tenant_id}#"
}
data "azurerm_client_config" "current" {}

resource "azurerm_virtual_network" "infra6" {
  name                = "mlops-cenkay-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_subnet" "infra7" {
  name                 = "mlops-cenkay-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.infra6.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_machine_learning_compute_cluster" "infra8" {
  name                          = "mlops-cenkay-compute"
  location                      = var.location
  vm_priority                   = "Dedicated"
  vm_size                       = "Standard_DS3_v2"
  machine_learning_workspace_id = "/subscriptions/e09d6db0-23cf-467b-8aca-90ad57a233f4/resourceGroups/rg-cenkay-0006-prod/providers/Microsoft.MachineLearningServices/workspaces/mlw-cenkay-0006-prod"
  subnet_resource_id            = azurerm_subnet.infra7.id

  scale_settings {
    min_node_count                       = 0
    max_node_count                       = 1
    scale_down_nodes_after_idle_duration = "PT120S"
  }

  identity {
    type = "SystemAssigned"
  }
}