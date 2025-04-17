resource "azurerm_service_plan" "apps" {
  #checkov:skip=CKV_AZURE_212: Ensure App Service has a minimum number of instances for failover - Not needed for Template App
  #checkov:skip=CKV_AZURE_225: Ensure the App Service Plan is zone redundant - Not needed for Template App
  name                = "${local.org}-asp-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.primary.name
  location            = module.primary_region.location
  # zone_balancing_enabled = true # for checkov 225
  # worker_count           = 2    # for checkov 212

  os_type  = "Linux"
  sku_name = var.apps_config.app_service_plan_sku

  tags = local.tags
}
