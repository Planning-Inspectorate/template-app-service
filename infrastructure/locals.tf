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

  #action groups
  all_action_groups = toset([
    "template-app-service"

  ])

  secrets = [
    "microsoft-provider-authentication-secret"
  ]

  # tflint-ignore: terraform_unused_declarations
  key_vault_refs = merge(
    {
      for k, v in azurerm_key_vault_secret.manual_secrets : k => "@Microsoft.KeyVault(SecretUri=${v.versionless_id})"
    },
    {
      "app-insights-connection-string" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.app_insights_connection_string.versionless_id})",
      "sql-app-connection-string"      = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.sql_app_connection_string.versionless_id})"
    }
  )

  # tflint-ignore: terraform_unused_declarations
  action_group_ids = {
    tech            = data.azurerm_monitor_action_group.common["tech"].id,
    service_manager = data.azurerm_monitor_action_group.common["service_manager"].id,
    iap             = data.azurerm_monitor_action_group.common["iap"].id,
    its             = data.azurerm_monitor_action_group.common["its"].id,
    info_sec        = data.azurerm_monitor_action_group.common["info_sec"].id
  }

  # #Frontdoor classic resource
  # template_primary_mapping = {
  #   url      = module.template_app_web.default_site_hostname,
  #   priority = 1
  # }

  # template_secondary_mapping = {
  #   url      = module.template_app_web.default_site_hostname,
  #   priority = 0
  # }

  # FD Classic
  # template_frontend = {
  #   frontend_endpoint = var.template_public_url
  #   app_service_urls = local.template_secondary_mapping.url != "" && var.feature_front_door_failover_enaled ? [
  #     local.template_primary_mapping,
  #     local.template_secondary_mapping] : [
  #     local.template_primary_mapping
  #   ]
  #   infer_backend_host_header = false
  #   name                      = "TemplateService"
  #   frontend_name             = "TemplateService"
  #   patterns_to_match         = ["/*"]
  #   ssl_certificate_name      = var.template_ssl_certificate_name
  # }
}
