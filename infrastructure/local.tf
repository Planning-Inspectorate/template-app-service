locals {
  org                = "pins"
  service_name       = "template"
  primary_location   = "uk-south"
  secondary_location = "uk-west"

  resource_suffix           = "${local.service_name}-${var.environment}"
  secondary_resource_suffix = "${local.service_name}-secondary-${var.environment}"
  # if equals "training" will shorten to "train" so storage account name length is upto 24 chars
  environment = var.environment == "training" ? "train" : var.environment
  # keep the suffix short for training env, as it can only be upto 24 characters total for azurerm_storage_account
  shorter_resource_suffix = var.environment == "training" ? "${local.service_name}-${"train"}" : local.resource_suffix

  secrets = []

  key_vault_refs = merge(
    {
      for k, v in azurerm_key_vault_secret.manual_secrets : k => "@Microsoft.KeyVault(SecretUri=${v.versionless_id})"
    },
    {
      "app-insights-connection-string" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.app_insights_connection_string.versionless_id})",
      "sql-app-connection-string"      = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.sql_app_connection_string.versionless_id})"
    }
  )

  tags = merge(
    var.tags,
    {
      CreatedBy   = "Terraform"
      Environment = var.environment
      ServiceName = local.service_name
      location    = local.primary_location
    }
  )

  action_group_ids = {
    tech            = "",
    service_manager = "",
    iap             = "",
    its             = "",
    info_sec        = ""
  }
}
