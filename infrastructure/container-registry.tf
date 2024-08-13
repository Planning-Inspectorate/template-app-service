# resource "azurerm_container_registry" "acr" {
#   #checkov:skip=CKV_AZURE_137: Admin account required so App services can pull containers when updated by pipeline
#   #checkov:skip=CKV_AZURE_139: Access over internet required so Azure DevOps can push/pull images
#   name                = "pinscr${replace(local.resource_suffix, "-", "")}"
#   resource_group_name = azurerm_resource_group.tooling.name
#   location            = azurerm_resource_group.tooling.location
#   admin_enabled       = true
#   sku                 = "Basic"

#   tags = local.tags
# }
