resource "azuread_application_registration" "template" {
  display_name = "Pins-AR-Template-Dev"
}

resource "azuread_application_password" "template" {
  application_id = azuread_application_registration.template.id
}