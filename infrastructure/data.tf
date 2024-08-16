data "azurerm_client_config" "current" {}

# data "azurerm_subscription" "current" {}

data "azurerm_virtual_network" "tooling" {
  name                = var.tooling_config.network_name
  resource_group_name = var.tooling_config.network_rg

  provider = azurerm.tooling
}

data "azurerm_virtual_network" "common_vnet" {
  name                = "pins-vnet-common-dev-ukw-001"
  resource_group_name = "pins-rg-common-dev-ukw-001"
}

data "azurerm_image" "packer_images" {
  name_regex          = "packer-image-"
  resource_group_name = azurerm_resource_group.primary.name
  sort_descending     = true
}
