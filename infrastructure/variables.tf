# variables should be sorted A-Z

# tflint-ignore: terraform_unused_declarations
variable "alerts_enabled" {
  description = "Whether to enable Azure Monitor alerts"
  type        = string
  default     = true
}

variable "apps_config" {
  description = "Config for the apps"
  type = object({
    app_service_plan_sku     = string
    node_environment         = string
    private_endpoint_enabled = bool

    logging = object({
      level_file   = string
      level_stdout = string
    })
  })
}

variable "common_config" {
  description = "Config for the common resources, such as action groups"
  type = object({
    resource_group_name = string
    action_group_names = object({
      tech            = string
      service_manager = string
      iap             = string
      its             = string
      info_sec        = string
    })
  })
}

variable "environment" {
  description = "The name of the environment in which resources will be deployed"
  type        = string
}

# #frontdoor Classic
# variable "feature_front_door_failover_enaled" {
#   description = "Whether or not the backend pools should be created with both the primary and secondary app service urls. This feature flag is temporary."
#   type        = bool
#   default     = false
# }

# #frontfoor Classic
# variable "front_door_waf_mode" {
#   description = "Indicates if the Web Application Firewall should be in Detection or Prevention mode"
#   type        = string
#   default     = "Detection"
# }

# # #frontdoor Classic
# variable "front_door_waf_template_redirect_path" {
#   description = "The URL to redirect a user to if a rule's action is Redirect"
#   type        = string
# }

variable "sql_config" {
  description = "Config for SQL Server and DB"
  type = object({
    admin = object({
      login_username = string
      object_id      = string
    })
    sku_name    = string
    max_size_gb = number
    retention = object({
      audit_days             = number
      short_term_days        = number
      long_term_weekly       = string
      long_term_monthly      = string
      long_term_yearly       = string
      long_term_week_of_year = number
    })
    public_network_access_enabled = bool
  })
}

variable "tags" {
  description = "A collection of tags to assign to taggable resources"
  type        = map(string)
  default     = {}
}


# #frontdoor Classic
# variable "template_ssl_certificate_name" {
#   description = "The SSL certificate name in the environment Key Vault for the applications service"
#   type        = string
#   default     = "unused"
# }

# #frontdoor Classic
# variable "template_public_url" {
#   description = "The public URL for the Template Service frontend web app"
#   type        = string
# }

# variable "tag_owner_michael" {
#   description = "Who created the resource and pushes into it"
#   type        = map(string)
#   default = {
#     Owner = "Michael"
#   }
# }

variable "tooling_config" {
  description = "Config for the tooling subscription resources"
  type = object({
    container_registry_name = string
    container_registry_rg   = string
    network_name            = string
    network_rg              = string
    subscription_id         = string
    frontdoor_name          = string
    frontdoor_rg            = string
    frontdoor_ep_name       = string
  })
}

variable "vnet_config" {
  description = "VNet configuration"
  type = object({
    address_space             = string
    main_subnet_address_space = string
    apps_subnet_address_space = string
  })
}

variable "web_app_domain" {
  description = "The domain for the web app"
  type        = string
}
