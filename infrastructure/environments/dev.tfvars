apps_config = {
  app_service_plan_sku     = "B1"
  node_environment         = "development"
  private_endpoint_enabled = false

  logging = {
    level_file   = "silent"
    level_stdout = "info"
  }
}

alerts_enabled = false

environment = "dev"

sql_config = {
  admin = {
    login_username = "pins-odt-sql-dev-appeals-bo"
    object_id      = "1c3b7d11-36c4-41ca-90b5-d15eafbe3b61"
  }
  sku_name    = "Basic"
  max_size_gb = 2
  retention = {
    audit_days             = 7
    short_term_days        = 7
    long_term_weekly       = "P1W"
    long_term_monthly      = "P1M"
    long_term_yearly       = "P1Y"
    long_term_week_of_year = 1
  }
  public_network_access_enabled = true
}

vnet_config = {
  address_space             = "10.15.0.0/22"
  apps_subnet_address_space = "10.15.0.0/24"
  main_subnet_address_space = "10.15.1.0/24"
}

web_app_domain = "template-service-dev.planninginspectorate.gov.uk"
