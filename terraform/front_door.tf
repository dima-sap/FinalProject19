# Front Door Profile
resource "azurerm_cdn_frontdoor_profile" "main" {
  count               = var.enable_front_door ? 1 : 0
  name                = "front-door"
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "Standard_AzureFrontDoor"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Front Door Endpoint
resource "azurerm_cdn_frontdoor_endpoint" "main" {
  count                    = var.enable_front_door ? 1 : 0
  name                     = "${var.project_name}-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main[0].id

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Origin Group for App Service
resource "azurerm_cdn_frontdoor_origin_group" "main" {
  count                    = var.enable_front_door ? 1 : 0
  name                     = "${var.project_name}-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main[0].id

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
    additional_latency_in_milliseconds = 50
  }

  health_probe {
    interval_in_seconds = 240
    path                = "/"
    protocol            = "Https"
    request_type        = "HEAD"
  }
}

# Origin - App Service
resource "azurerm_cdn_frontdoor_origin" "main" {
  count                         = var.enable_front_door ? 1 : 0
  name                          = "${var.project_name}-app-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main[0].id

  enabled                        = true
  host_name                      = azurerm_linux_web_app.main.default_hostname
  http_port                      = 80
  https_port                     = 443
  origin_host_header            = azurerm_linux_web_app.main.default_hostname
  priority                      = 1
  weight                        = 1000
  certificate_name_check_enabled = true
}

# Front Door Route
resource "azurerm_cdn_frontdoor_route" "main" {
  count                         = var.enable_front_door ? 1 : 0
  name                          = "${var.project_name}-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main[0].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main[0].id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.main[0].id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match     = ["/*"]
  forwarding_protocol   = "HttpsOnly"
  link_to_default_domain = true
  https_redirect_enabled = true
}
