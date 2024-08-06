resource "azurerm_virtual_network" "main" {
  name                = "${local.org}-vnet-${local.resource_suffix}"
  location            = module.primary_region.location
  resource_group_name = azurerm_resource_group.primary.name
  address_space       = [var.vnet_config.address_space]

  tags = var.tags
}

resource "azurerm_subnet" "apps" {
  name                 = "${local.org}-snet-${local.service_name}-apps-${var.environment}"
  resource_group_name  = azurerm_resource_group.primary.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.vnet_config.apps_subnet_address_space]

  # for app services
  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

resource "azurerm_subnet" "main" {
  name                 = "${local.org}-snet-${local.resource_suffix}"
  resource_group_name  = azurerm_resource_group.primary.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.vnet_config.main_subnet_address_space]
}

## peer to tooling VNET for DevOps agents
resource "azurerm_virtual_network_peering" "bo_to_tooling" {
  name                      = "${local.org}-peer-${local.service_name}-to-tooling-${var.environment}"
  remote_virtual_network_id = data.azurerm_virtual_network.tooling.id
  resource_group_name       = azurerm_virtual_network.main.resource_group_name
  virtual_network_name      = azurerm_virtual_network.main.name
}

resource "azurerm_virtual_network_peering" "tooling_to_bo" {
  name                      = "${local.org}-peer-tooling-to-${local.service_name}-${var.environment}"
  remote_virtual_network_id = azurerm_virtual_network.main.id
  resource_group_name       = var.tooling_config.network_rg
  virtual_network_name      = var.tooling_config.network_name

  provider = azurerm.tooling
}

## peer to Horizon for linked case integration
resource "azurerm_virtual_network_peering" "bo_to_horizon" {
  # only deploy if configured to connect to horizon
  count = var.horizon_infra_config.deploy_connections ? 1 : 0

  name                      = "${local.org}-peer-${local.service_name}-to-horizon-${var.environment}"
  remote_virtual_network_id = data.azurerm_virtual_network.horizon_vnet[0].id
  resource_group_name       = azurerm_virtual_network.main.resource_group_name
  virtual_network_name      = azurerm_virtual_network.main.name
}

## DNS Zones for Azure Services
## Private DNS Zones exist in the tooling subscription and are shared
## here we link them to the VNet

data "azurerm_private_dns_zone" "app_config" {
  name                = "privatelink.azconfig.io"
  resource_group_name = var.tooling_config.network_rg

  provider = azurerm.tooling
}
resource "azurerm_private_dns_zone_virtual_network_link" "app_config" {
  name                  = "${local.org}-vnetlink-app-config-${local.resource_suffix}"
  resource_group_name   = var.tooling_config.network_rg
  private_dns_zone_name = data.azurerm_private_dns_zone.app_config.name
  virtual_network_id    = azurerm_virtual_network.main.id

  provider = azurerm.tooling
}

data "azurerm_private_dns_zone" "app_service" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.tooling_config.network_rg

  provider = azurerm.tooling
}
resource "azurerm_private_dns_zone_virtual_network_link" "app_service" {
  name                  = "${local.org}-vnetlink-app-service-${local.resource_suffix}"
  resource_group_name   = var.tooling_config.network_rg
  private_dns_zone_name = data.azurerm_private_dns_zone.app_service.name
  virtual_network_id    = azurerm_virtual_network.main.id

  provider = azurerm.tooling
}

data "azurerm_private_dns_zone" "database" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.tooling_config.network_rg

  provider = azurerm.tooling
}
resource "azurerm_private_dns_zone_virtual_network_link" "database" {
  name                  = "${local.org}-vnetlink-db-${local.resource_suffix}"
  resource_group_name   = var.tooling_config.network_rg
  private_dns_zone_name = data.azurerm_private_dns_zone.database.name
  virtual_network_id    = azurerm_virtual_network.main.id

  provider = azurerm.tooling
}
