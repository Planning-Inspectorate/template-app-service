locals {
  org              = "pins"
  service_name     = "template"
  primary_location = "uk-south"

  resource_suffix = "${local.service_name}-${var.environment}"

  tags = merge(
    var.tags,
    {
      CreatedBy   = "Terraform"
      Environment = var.environment
      location    = local.primary_location
      Owner       = "DevOps"
      ServiceName = local.service_name
    }
  )

  # secrets = []

  # key_vault_refs = merge(
  #   {
  #     for k, v in azurerm_key_vault_secret.manual_secrets : k => "@Microsoft.KeyVault(SecretUri=${v.versionless_id})"
  #   },
  #   {
  #     "app-insights-connection-string" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.app_insights_connection_string.versionless_id})",
  #     "sql-app-connection-string"      = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.sql_app_connection_string.versionless_id})"
  #   }
  # )

  # action_group_ids = {
  #   tech            = "",
  #   service_manager = "",
  #   iap             = "",
  #   its             = "",
  #   info_sec        = ""
  # }
}
