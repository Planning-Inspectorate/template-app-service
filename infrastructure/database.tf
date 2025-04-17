resource "azurerm_mssql_server" "primary" {
  #checkov:skip=CKV_AZURE_113: Public access enabled for testing
  #checkov:skip=CKV_AZURE_23: Auditing to be added later
  #checkov:skip=CKV_AZURE_24: Auditing to be added later
  #checkov:skip=CKV2_AZURE_2: setup alerts and vulnerability assessments
  name                          = "${local.org}-sql-${local.service_name}-primary-${var.environment}"
  resource_group_name           = azurerm_resource_group.primary.name
  location                      = module.primary_region.location
  version                       = "12.0"
  administrator_login           = random_id.sql_admin_username.b64_url
  administrator_login_password  = random_password.sql_admin_password.result
  minimum_tls_version           = "1.2"
  public_network_access_enabled = var.sql_config.public_network_access_enabled

  azuread_administrator {
    login_username = var.sql_config.admin.login_username
    object_id      = var.sql_config.admin.object_id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

# resource "azurerm_storage_account" "primary" {
#   name                     = "${local.org}-sql-${local.service_name}-primary-${var.environment}"
#   resource_group_name      = azurerm_resource_group.primary.name
#   location                 = azurerm_resource_group.primary.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

# resource "azurerm_mssql_server_extended_auditing_policy" "primary" {
#   server_id                               = azurerm_mssql_server.primary.id
#   storage_endpoint                        = azurerm_storage_account.primary.primary_blob_endpoint
#   storage_account_access_key              = azurerm_storage_account.primary.primary_access_key
#   storage_account_access_key_is_secondary = true
#   retention_in_days                       = 120
# }

resource "azurerm_private_endpoint" "sql_primary" {
  name                = "${local.org}-pe-${local.service_name}-sql-${var.environment}"
  resource_group_name = azurerm_resource_group.primary.name
  location            = module.primary_region.location
  subnet_id           = azurerm_subnet.main.id

  private_dns_zone_group {
    name                 = "sqlserverprivatednszone"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.database.id]
  }

  private_service_connection {
    name                           = "privateendpointconnection"
    private_connection_resource_id = azurerm_mssql_server.primary.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  tags = local.tags
}

resource "azurerm_mssql_database" "primary" {
  # geo_redundant_backup_enabled = true this is not expected here, must be an older version of TF that expects it and perhaps checkov is tied to that version?
  name           = "${local.org}-sqldb-${local.resource_suffix}"
  server_id      = azurerm_mssql_server.primary.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  sku_name       = var.sql_config.sku_name
  max_size_gb    = var.sql_config.max_size_gb
  ledger_enabled = true
  zone_redundant = true

  short_term_retention_policy {
    retention_days = var.sql_config.retention.short_term_days
  }

  long_term_retention_policy {
    weekly_retention  = var.sql_config.retention.long_term_weekly
    monthly_retention = var.sql_config.retention.long_term_monthly
    yearly_retention  = var.sql_config.retention.long_term_yearly
    week_of_year      = var.sql_config.retention.long_term_week_of_year
  }

  tags = local.tags
}

resource "azurerm_key_vault_secret" "sql_admin_connection_string" {
  key_vault_id = azurerm_key_vault.main.id
  name         = "${local.service_name}-sql-admin-connection-string"
  value = join(
    ";",
    [
      "sqlserver://${azurerm_mssql_server.primary.fully_qualified_domain_name}",
      "database=${azurerm_mssql_database.primary.name}",
      "user=${random_id.sql_admin_username.b64_url}",
      "password=${random_password.sql_admin_password.result}",
      "trustServerCertificate=false"
    ]
  )
  expiration_date = timeadd(timestamp(), "8760h") # Sets expiration to 1 year from 15/04/25
  content_type    = "connection-string"

  tags = local.tags
}

resource "azurerm_key_vault_secret" "sql_app_connection_string" {
  key_vault_id = azurerm_key_vault.main.id
  name         = "${local.service_name}-sql-app-connection-string"
  value = join(
    ";",
    [
      "sqlserver://${azurerm_mssql_server.primary.fully_qualified_domain_name}",
      "database=${azurerm_mssql_database.primary.name}",
      "user=${random_id.sql_app_username.b64_url}",
      "password=${random_password.sql_app_password.result}",
      "trustServerCertificate=false"
    ]
  )
  content_type    = "connection-string"
  expiration_date = timeadd(timestamp(), "8760h") # Sets expiration to 1 year from when the pipeline is run

  tags = local.tags
}

resource "random_id" "sql_admin_username" {
  byte_length = 6
  prefix      = "${local.service_name}_admin_"
}

resource "random_password" "sql_admin_password" {
  length           = 32
  special          = true
  override_special = "#&-_+"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "random_id" "sql_app_username" {
  byte_length = 6
  prefix      = "${local.service_name}_app_"
}

resource "random_password" "sql_app_password" {
  length           = 32
  special          = true
  override_special = "#&-_+"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}
