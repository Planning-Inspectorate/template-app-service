# resource "azurerm_frontdoor_firewall_policy" "template_frontend" {
#   name                              = replace("pinswaf${local.service_name}${local.resource_suffix}", "-", "")
#   resource_group_name               = azurerm_resource_group.primary.name
#   enabled                           = true
#   mode                              = var.front_door_waf_mode
#   redirect_url                      = "https://${var.template_public_url}${var.front_door_waf_template_redirect_path}"
#   custom_block_response_status_code = 429

#   managed_rule {
#     type    = "DefaultRuleSet"
#     version = "1.0"
#   }
#   custom_rule {
#     name                           = "RateLimitHttpRequest"
#     action                         = "Block"
#     enabled                        = true
#     priority                       = 100
#     type                           = "RateLimitRule"
#     rate_limit_duration_in_minutes = 1
#     rate_limit_threshold           = 300

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

#   custom_rule {
#     name     = "IpBlock"
#     action   = "Block"
#     enabled  = true
#     priority = 10
#     type     = "MatchRule"

#     match_condition {
#       match_variable     = "RemoteAddr"
#       operator           = "IPMatch"
#       negation_condition = false
#       match_values = [
#         "10.255.255.255" # placeholder value
#       ]
#     }
#   }

#   tags = local.tags

#   lifecycle {
#     ignore_changes = [
#       # match the second custom rule (IpBlock) and ignore the match values (IPs)
#       # managed in Portal
#       custom_rule[1].match_condition[0].match_values
#     ]
#   }
# }