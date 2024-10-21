output "template_secondary_mapping_url" {
  description = "The URL of the web frontend App Service"
  value       = module.template_app_web.default_site_hostname
}


output "template_primary_mapping_url" {
  description = "The URL of the web frontend App Service"
  value       = module.template_app_web.default_site_hostname
}