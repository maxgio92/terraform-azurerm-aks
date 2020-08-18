provider "azurerm" {
  features {}
}

resource "random_id" "prefix" {
  byte_length = 8
}
resource "azurerm_resource_group" "main" {
  name     = "${random_id.prefix.hex}-rg"
  location = var.location
}

module network {
  source              = "Azure/network/azurerm"
  address_space       = "10.251.0.0/16"
  subnet_prefixes     = ["10.251.0.0/24"]
  resource_group_name = azurerm_resource_group.main.name
}

module aks {
  source              = "../.."
  prefix              = "prefix-${random_id.prefix.hex}"
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.network.vnet_subnets[0]
}

module aks_without_monitor {
  source                         = "../.."
  prefix                         = "prefix2-${random_id.prefix.hex}"
  resource_group_name            = azurerm_resource_group.main.name
  enable_log_analytics_workspace = false
  subnet_id                      = module.network.vnet_subnets[0]
}
