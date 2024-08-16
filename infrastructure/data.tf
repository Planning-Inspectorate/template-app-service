data "azurerm_client_config" "current" {}

# data "azurerm_subscription" "current" {} # This is used in docs storage on the back office

data "azurerm_virtual_network" "tooling" {
  name                = var.tooling_config.network_name
  resource_group_name = var.tooling_config.network_rg

  provider = azurerm.tooling
}

data "azurerm_image" "packer_images" {
  name_regex          = "packer_images"
  sort_descending     = true
  resource_group_name = azurerm_resource_group.primary.name
}
