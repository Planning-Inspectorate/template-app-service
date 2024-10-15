# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/frontdoor 
resource "azurerm_frontdoor" "common" {
  #checkov:skip=CKV_AZURE_121: WAF implemented but Checkov still fails: https://github.com/bridgecrewio/checkov/issues/2617
  name                = "pins-fd-${local.service_name}-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.primary.name

  backend_pool_load_balancing {
    name                            = "Default"
    sample_size                     = 4
    successful_samples_required     = 2
    additional_latency_milliseconds = 0
  }

  backend_pool_health_probe {
    enabled             = true
    name                = "Http"
    path                = "/health"
    protocol            = "Http"
    probe_method        = "GET"
    interval_in_seconds = 120
  }

  backend_pool_settings {
    enforce_backend_pools_certificate_name_check = false
    backend_pools_send_receive_timeout_seconds   = 120
  }

  frontend_endpoint {
    name                                    = local.template_frontend.frontend_name
    host_name                               = local.template_frontend.frontend_endpoint
    web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.template_frontend.id
  }

  backend_pool {
    name                = local.template_frontend.name
    load_balancing_name = "Default"
    health_probe_name   = "Http"

    dynamic "backend" {
      for_each = local.template_frontend.app_service_urls
      iterator = app_service_url

      content {
        enabled     = true
        address     = app_service_url.value["url"]
        host_header = local.template_frontend.infer_backend_host_header ? "" : app_service_url.value["url"]
        http_port   = 80
        https_port  = 443
        priority    = app_service_url.value["priority"]
        weight      = 100
      }
    }
  }

  routing_rule {
    enabled            = true
    name               = local.template_frontend.name
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = local.template_frontend.patterns_to_match
    frontend_endpoints = [local.template_frontend.frontend_name]

    forwarding_configuration {
      backend_pool_name      = local.template_frontend.name
      cache_enabled          = false
      cache_query_parameters = []
      forwarding_protocol    = "MatchRequest"
    }
  }


}
# --------------------------------FRONT DOOR STANDARD CODE BELOW---------------------------------------------------------------

# resource "azurerm_cdn_frontdoor_profile" "web" {
#   name                = "${local.org}-fd-${local.service_name}-web-${var.environment}"
#   resource_group_name = azurerm_resource_group.primary.name
#   sku_name            = "Standard_AzureFrontDoor"

#   tags = local.tags
# }

# resource "azurerm_cdn_frontdoor_endpoint" "web" {
#   name                     = "${local.org}-fd-${local.service_name}-web-${var.environment}"
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.web.id

#   tags = local.tags
# }

# resource "azurerm_cdn_frontdoor_origin_group" "web" {
#   name                     = "${local.org}-fd-${local.service_name}-web-${var.environment}"
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.web.id
#   session_affinity_enabled = true

#   health_probe {
#     interval_in_seconds = 240
#     path                = "/"
#     protocol            = "Https"
#     request_type        = "HEAD"
#   }

#   load_balancing {
#     additional_latency_in_milliseconds = 0
#     sample_size                        = 16
#     successful_samples_required        = 3
#   }
# }

# resource "azurerm_cdn_frontdoor_origin" "web" {
#   name                          = "${local.org}-fd-${local.service_name}-web-${var.environment}"
#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.web.id
#   enabled                       = true

#   certificate_name_check_enabled = true

#   host_name          = module.template_app_web.default_site_hostname
#   origin_host_header = module.template_app_web.default_site_hostname
#   http_port          = 80
#   https_port         = 443
#   priority           = 1
#   weight             = 1000
# }

# resource "azurerm_cdn_frontdoor_custom_domain" "web" {
#   name                     = "${local.org}-fd-${local.service_name}-web-${var.environment}"
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.web.id
#   host_name                = var.web_app_domain

#   tls {
#     certificate_type    = "ManagedCertificate"
#     minimum_tls_version = "TLS12"
#   }
# }

# resource "azurerm_cdn_frontdoor_route" "web" {
#   name                          = "${local.org}-fd-${local.service_name}-web-${var.environment}"
#   cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.web.id
#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.web.id
#   cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.web.id]

#   forwarding_protocol    = "MatchRequest"
#   https_redirect_enabled = true
#   patterns_to_match      = ["/*"]
#   supported_protocols    = ["Http", "Https"]


#   cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.web.id]
#   link_to_default_domain          = false
# }

# resource "azurerm_cdn_frontdoor_custom_domain_association" "web" {
#   cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.web.id
#   cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.web.id]
# }

# # WAF policy
# resource "azurerm_cdn_frontdoor_firewall_policy" "web" {
#   name                              = replace("${local.org}-waf-${local.service_name}-web-${var.environment}", "-", "")
#   resource_group_name               = azurerm_resource_group.primary.name
#   sku_name                          = "Standard_AzureFrontDoor"
#   enabled                           = true
#   mode                              = "Prevention"
#   custom_block_response_status_code = 403

#   tags = local.tags

#   custom_rule {
#     name                           = "RateLimitHttpRequest"
#     enabled                        = true
#     priority                       = 100
#     rate_limit_duration_in_minutes = 1
#     rate_limit_threshold           = 300
#     type                           = "RateLimitRule"
#     action                         = "Block"

#     match_condition {
#       match_variable = "RequestMethod"
#       operator       = "Equal"
#       match_values = [
#         "GET",
#         "POST",
#         "PUT",
#         "DELETE",
#         "COPY",
#         "MOVE",
#         "HEAD",
#         "OPTIONS"
#       ]
#     }
#   }

#   # managed_rule {
#   #   type    = "Microsoft_DefaultRuleSet"
#   #   version = "2.1"
#   #   action  = "Log"
#   # }
# }

# resource "azurerm_cdn_frontdoor_security_policy" "web" {
#   name                     = replace("${local.org}-sec-${local.service_name}-web-${var.environment}", "-", "")
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.web.id

#   security_policies {
#     firewall {
#       cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.web.id

#       association {
#         domain {
#           cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.web.id
#         }
#         patterns_to_match = ["/*"]
#       }
#     }
#   }
# }

# # moinitoring
# resource "azurerm_monitor_diagnostic_setting" "web_front_door" {
#   name                       = "${local.org}-fd-mds-${local.service_name}-web-${var.environment}"
#   target_resource_id         = azurerm_cdn_frontdoor_profile.web.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

#   enabled_log {
#     category = "FrontdoorWebApplicationFirewallLog"
#   }

#   metric {
#     category = "AllMetrics"
#   }

#   lifecycle {
#     ignore_changes = [
#       enabled_log,
#       metric
#     ]
#   }
# }
