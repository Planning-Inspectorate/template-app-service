# resource "azurerm_subnet" "packer_images" {
#   name                 = "pins-snet-packer-images-${local.resource_suffix}"
#   resource_group_name  = azurerm_resource_group.primary.name
#   virtual_network_name = azurerm_virtual_network.main.name
#   address_prefixes     = [var.vnet_config.packer_images]
# }


## Peer to DEV Common VNET for Bastion access to test packer images
# resource "azurerm_virtual_network_peering" "template_to_common" {
#   name                      = "${local.org}-peer-${local.service_name}-to-common-${var.environment}"
#   resource_group_name       = azurerm_virtual_network.main.resource_group_name
#   remote_virtual_network_id = data.azurerm_virtual_network.common_vnet.id
#   virtual_network_name      = azurerm_virtual_network.main.name
# }

# resource "azurerm_virtual_network_peering" "common_to_template" {
#   name                      = "${local.org}-peer-common-to-${local.service_name}-${var.environment}"
#   resource_group_name       = data.azurerm_virtual_network.common_vnet.resource_group_name
#   remote_virtual_network_id = azurerm_virtual_network.main.id
#   virtual_network_name      = data.azurerm_virtual_network.common_vnet.name
# }
