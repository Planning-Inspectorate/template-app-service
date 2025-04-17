module "primary_region" {
  # checkov:skip=CKV_TF_1: Trusted source
  # checkov:skip=CKV_TF_2: Trusted source
  source  = "claranet/regions/azurerm"
  version = "7.3.1"

  azure_region = local.primary_location
}

resource "azurerm_resource_group" "primary" {
  name     = format("%s-rg-%s", local.org, local.resource_suffix)
  location = module.primary_region.location

  tags = local.tags
}

resource "azurerm_key_vault" "main" {
  name                        = format("%s-kv-%s", local.org, local.resource_suffix)
  location                    = module.primary_region.location
  resource_group_name         = azurerm_resource_group.primary.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true
  enable_rbac_authorization   = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  sku_name = "standard"

  tags = local.tags
}

resource "azurerm_key_vault_access_policy" "admins" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = "1f09c724-3d26-4a14-b52b-5af4acafab55" # Entra Group "All DevOps"

  certificate_permissions = ["Create", "Get", "Import", "List"]
  key_permissions         = ["Create", "Get", "List"]
  secret_permissions      = ["Get", "List", "Set"]
  storage_permissions     = ["Get", "List", "Set"]

}

# secrets to be manually populated?
resource "azurerm_key_vault_secret" "manual_secrets" {
  for_each = toset(local.secrets)

  key_vault_id    = azurerm_key_vault.main.id
  name            = each.value
  value           = "<terraform_placeholder>"
  content_type    = "plaintext"
  expiration_date = timeadd(timestamp(), "8760h") # Sets expiration to 1 year from when the pipeline is run

  tags = local.tags

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
