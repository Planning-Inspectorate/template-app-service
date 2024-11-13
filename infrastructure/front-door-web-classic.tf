# # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/frontdoor 
# resource "azurerm_frontdoor" "common" {
#   #checkov:skip=CKV_AZURE_121: WAF implemented but Checkov still fails: https://github.com/bridgecrewio/checkov/issues/2617
#   name                = "pins-fd-${local.service_name}-${local.resource_suffix}"
#   resource_group_name = azurerm_resource_group.primary.name

#   backend_pool_load_balancing {
#     name                            = "Default"
#     sample_size                     = 4
#     successful_samples_required     = 2
#     additional_latency_milliseconds = 0
#   }

#   backend_pool_health_probe {
#     enabled             = true
#     name                = "Http"
#     path                = "/health"
#     protocol            = "Http"
#     probe_method        = "GET"
#     interval_in_seconds = 120
#   }

#   backend_pool_settings {
#     enforce_backend_pools_certificate_name_check = false
#     backend_pools_send_receive_timeout_seconds   = 120
#   }

#   #default with froontdoor name
#   frontend_endpoint {
#     name                                    = "pins-fd-${local.service_name}-${local.resource_suffix}"
#     host_name                               = "pins-fd-${local.service_name}-${local.resource_suffix}.azurefd.net"
#     web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.template_frontend.id
#   }

#   backend_pool {
#     name                = local.template_frontend.name
#     load_balancing_name = "Default"
#     health_probe_name   = "Http"

#     dynamic "backend" {
#       for_each = local.template_frontend.app_service_urls
#       iterator = app_service_url

#       content {
#         enabled     = true
#         address     = app_service_url.value["url"]
#         host_header = local.template_frontend.infer_backend_host_header ? "" : app_service_url.value["url"]
#         http_port   = 80
#         https_port  = 443
#         priority    = app_service_url.value["priority"]
#         weight      = 100
#       }
#     }
#   }

#   routing_rule {
#     enabled            = true
#     name               = "Default"
#     accepted_protocols = ["Http", "Https"]
#     patterns_to_match  = ["/*"]
#     frontend_endpoints = ["pins-fd-${local.service_name}-${local.resource_suffix}"]

#     forwarding_configuration {
#       backend_pool_name      = local.template_frontend.name
#       cache_enabled          = false
#       cache_query_parameters = []
#       forwarding_protocol    = "MatchRequest"
#     }
#   }

#   #For template host
#   # frontend_endpoint {
#   #   name                                    = local.template_frontend.frontend_name
#   #   host_name                               = local.template_frontend.frontend_endpoint
#   #   web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.template_frontend.id
#   # }
#   # routing_rule {
#   #   enabled            = true
#   #   name               = local.template_frontend.name
#   #   accepted_protocols = ["Http", "Https"]
#   #   patterns_to_match  = local.template_frontend.patterns_to_match
#   #   frontend_endpoints = [local.template_frontend.frontend_name]

#   #   forwarding_configuration {
#   #     backend_pool_name      = local.template_frontend.name
#   #     cache_enabled          = false
#   #     cache_query_parameters = []
#   #     forwarding_protocol    = "MatchRequest"
#   #   }
#   # }

#   # tags = local.tags
# }
# # #Frontdoor https configuration
# # resource "azurerm_frontdoor_custom_https_configuration" "template_https_0" {
# #   frontend_endpoint_id              = azurerm_frontdoor.common.frontend_endpoints[local.template_frontend.frontend_name]
# #   custom_https_provisioning_enabled = true

# #   custom_https_configuration {
# #     certificate_source = "FrontDoor"
# #   }
# # }