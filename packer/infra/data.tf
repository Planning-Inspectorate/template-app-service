data "azurerm_resource_group" "template_rg" {
  name = "pins-rg-template-dev"
}

data "azurerm_image" "packer_images" {
  name_regex          = "image-"
  resource_group_name = "pins-rg-template-dev"
  sort_descending     = true
}

data "azurerm_virtual_network" "template_vnet" {
  name                = "pins-vnet-template-dev"
  resource_group_name = "pins-rg-template-dev"
}

data "azurerm_key_vault" "template_key_vault" {
  name                = "pins-kv-template-dev"
  resource_group_name = "pins-rg-template-dev"
}
