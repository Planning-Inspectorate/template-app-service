# locals {
#   org              = "pins"
#   service_name     = "template"
#   primary_location = "uk-south"

#   resource_suffix = "${local.service_name}-${var.environment}"

#   tags = merge(
#     var.tags,
#     {
#       CreatedBy   = "Terraform"
#       Environment = var.environment
#       location    = local.primary_location
#       Owner       = "DevOps"
#       ServiceName = local.service_name
#     }
#   )

#   # Packer Images
#   test_image = {
#     main = {
#       name     = "pins-vmss-packer-${local.resource_suffix}"
#       nic_name = "pins-vnet-azure-agents-nic-test-${local.resource_suffix}"
#     }
#   }
# }

# resource "azurerm_container_registry" "acr" {
#   #checkov:skip=CKV_AZURE_137: Admin account required so App services can pull containers when updated by pipeline
#   #checkov:skip=CKV_AZURE_139: Access over internet required so Azure DevOps can push/pull images
#   #checkov:skip=CKV_AZURE_163: Enable vulnerability scanning for container images
#   name                = "pinscr${replace(local.resource_suffix, "-", "")}"
#   resource_group_name = azurerm_resource_group.primary.name
#   location            = azurerm_resource_group.primary.location
#   admin_enabled       = true
#   sku                 = "Basic"

#   tags = local.tags
# }

# data "azurerm_image" "packer_images" {
#   name_regex          = "packer-image-"
#   resource_group_name = azurerm_resource_group.primary.name
#   sort_descending     = true
# }


# data "azurerm_virtual_network" "common_vnet" {
#   name                = "pins-vnet-common-dev-ukw-001"
#   resource_group_name = "pins-rg-common-dev-ukw-001"
# }


# module "primary_region" {
#   source  = "claranet/regions/azurerm"
#   version = "7.1.1"

#   azure_region = local.primary_location
# }

# resource "azurerm_resource_group" "primary" {
#   name     = format("%s-rg-%s", local.org, local.resource_suffix)
#   location = module.primary_region.location

#   tags = local.tags
# }

# ## data call on the Key Vault?
# resource "random_password" "packer_admin_password" {
#   length  = 20
#   special = true
# }

# resource "azurerm_key_vault_secret" "agents_admin_password" {
#   #checkov:skip=CKV_AZURE_41: TODO: Secret rotation
#   name            = "packer-admin-password"
#   value           = random_password.packer_admin_password.result
#   key_vault_id    = azurerm_key_vault.main.id
#   expiration_date = "2025-01-01T00:00:00Z"
#   content_type    = "text/plain"

#   tags = local.tags
# }

# resource "azurerm_linux_virtual_machine_scale_set" "azure_devops_agent_pool" {
#   #checkov:skip=CKV_AZURE_49: SSH key authentication not required
#   #checkov:skip=CKV_AZURE_97: Encryption at host not required
#   #checkov:skip=CKV_AZURE_149: Password authentication required
#   for_each = local.test_image

#   name                = each.value["name"]
#   resource_group_name = azurerm_resource_group.primary.name
#   location            = azurerm_resource_group.primary.location
#   sku                 = "Standard_DS2_v2"
#   instances           = 1

#   overprovision          = false
#   single_placement_group = false

#   admin_username                  = "adminuser"
#   admin_password                  = azurerm_key_vault_secret.agents_admin_password.value
#   disable_password_authentication = false

#   platform_fault_domain_count = 1

#   source_image_id = data.azurerm_image.packer_images.id

#   boot_diagnostics {
#     storage_account_uri = null
#   }

#   network_interface {
#     enable_accelerated_networking = true
#     name                          = each.value["nic_name"]
#     primary                       = true

#     ip_configuration {
#       name      = "default"
#       primary   = true
#       subnet_id = azurerm_subnet.packer_images.id
#     }
#   }

#   os_disk {
#     caching              = "ReadOnly"
#     storage_account_type = "Standard_LRS"

#     diff_disk_settings {
#       option = "Local"
#     }
#   }

#   lifecycle {
#     ignore_changes = [
#       automatic_instance_repair,
#       automatic_os_upgrade_policy,
#       extension,
#       instances,
#       tags
#     ]
#   }

#   tags = local.tags
# }

# variable "tags" {
#   description = "A collection of tags to assign to taggable resources"
#   type        = map(string)
#   default     = {}
# }

# variable "environment" {
#   description = "The name of the environment in which resources will be deployed"
#   type        = string
# }


# resource "azurerm_subnet" "packer_images" {
#   name                 = "pins-snet-packer-images-${local.resource_suffix}"
#   resource_group_name  = azurerm_resource_group.primary.name
#   virtual_network_name = azurerm_virtual_network.main.name
#   address_prefixes     = [var.vnet_config.packer_images]
# }
