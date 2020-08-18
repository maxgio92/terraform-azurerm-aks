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

module aks {
  source              = "../.."
  prefix              = "prefix-${random_id.prefix.hex}"
  resource_group_name = azurerm_resource_group.main.name
}

module aks_without_monitor {
  source                         = "../.."
  prefix                         = "prefix2-${random_id.prefix.hex}"
  resource_group_name            = azurerm_resource_group.main.name
  enable_log_analytics_workspace = false
}
