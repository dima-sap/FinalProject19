# Resource Group
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# Virtual Network
output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

# PostgreSQL
output "postgresql_server_name" {
  description = "Name of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.main.name
}

output "postgresql_server_fqdn" {
  description = "FQDN of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "postgresql_database_name" {
  description = "Name of the PostgreSQL database"
  value       = azurerm_postgresql_flexible_server_database.main.name
}

# Private Endpoint
output "private_endpoint_name" {
  description = "Name of the PostgreSQL private endpoint"
  value       = azurerm_private_endpoint.postgres.name
}

output "private_endpoint_ip" {
  description = "Private IP address of the PostgreSQL private endpoint"
  value       = azurerm_private_endpoint.postgres.private_service_connection[0].private_ip_address
}

# App Service
output "app_service_name" {
  description = "Name of the App Service"
  value       = azurerm_linux_web_app.main.name
}

output "app_service_default_hostname" {
  description = "Default hostname of the App Service"
  value       = azurerm_linux_web_app.main.default_hostname
}

output "app_service_url" {
  description = "URL of the App Service"
  value       = "https://${azurerm_linux_web_app.main.default_hostname}"
}

# App Service Plan
output "app_service_plan_name" {
  description = "Name of the App Service Plan"
  value       = azurerm_service_plan.main.name
}

output "app_service_plan_sku" {
  description = "SKU of the App Service Plan"
  value       = azurerm_service_plan.main.sku_name
}

# Front Door (conditional outputs)
output "front_door_profile_name" {
  description = "Name of the Front Door profile"
  value       = var.enable_front_door ? azurerm_cdn_frontdoor_profile.main[0].name : null
}

output "front_door_endpoint_hostname" {
  description = "Hostname of the Front Door endpoint"
  value       = var.enable_front_door ? azurerm_cdn_frontdoor_endpoint.main[0].host_name : null
}

output "front_door_url" {
  description = "URL of the Front Door endpoint"
  value       = var.enable_front_door ? "https://${azurerm_cdn_frontdoor_endpoint.main[0].host_name}" : null
}

# Database Connection String (for reference, but sensitive)
output "database_connection_string" {
  description = "PostgreSQL connection string (sensitive)"
  value       = "postgresql://${var.db_admin_username}:${var.db_admin_password}@${azurerm_postgresql_flexible_server.main.fqdn}/${azurerm_postgresql_flexible_server_database.main.name}?sslmode=require"
  sensitive   = true
}
