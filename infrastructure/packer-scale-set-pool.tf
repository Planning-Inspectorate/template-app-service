resource "azurerm_linux_virtual_machine_scale_set" "azure_devops_agent_pool" {
  #checkov:skip=CKV_AZURE_49: SSH key authentication not required
  #checkov:skip=CKV_AZURE_97: Encryption at host not required
  #checkov:skip=CKV_AZURE_149: Password authentication required
  for_each = local.test_image

  name                = each.value["name"]
  resource_group_name = azurerm_resource_group.primary.name
  location            = azurerm_resource_group.primary.location
  sku                 = "Standard_DS2_v2"
  instances           = 1

  overprovision          = false
  single_placement_group = false

  admin_username                  = "adminuser"
  admin_password                  = azurerm_key_vault_secret.agents_admin_password.value
  disable_password_authentication = false

  platform_fault_domain_count = 1

  source_image_id = data.azurerm_image.packer_images.id

  boot_diagnostics {
    storage_account_uri = null
  }

  network_interface {
    enable_accelerated_networking = true
    name                          = each.value["nic_name"]
    primary                       = true

    ip_configuration {
      name      = "default"
      primary   = true
      subnet_id = azurerm_subnet.packer_images.id
    }
  }

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"

    diff_disk_settings {
      option = "Local"
    }
  }

  lifecycle {
    ignore_changes = [
      automatic_instance_repair,
      automatic_os_upgrade_policy,
      extension,
      instances,
      tags
    ]
  }

  tags = local.tags
}
