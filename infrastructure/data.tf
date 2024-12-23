data "azurerm_client_config" "current" {}

# data "azurerm_subscription" "current" {}

data "azurerm_virtual_network" "tooling" {
  name                = var.tooling_config.network_name
  resource_group_name = var.tooling_config.network_rg

  provider = azurerm.tooling
}

data "azurerm_monitor_action_group" "common" {
  for_each = tomap(var.common_config.action_group_names)

  resource_group_name = var.common_config.resource_group_name
  name                = each.value
}

data "azurerm_cdn_frontdoor_profile" "web" {
  name                = var.tooling_config.frontdoor_name
  resource_group_name = var.tooling_config.frontdoor_rg
  provider            = azurerm.front_door
}

data "azurerm_cdn_frontdoor_endpoint" "web" {
  name                = var.tooling_config.frontdoor_ep_name
  resource_group_name = var.tooling_config.frontdoor_rg
  profile_name        = var.tooling_config.frontdoor_name
  provider            = azurerm.front_door
}
