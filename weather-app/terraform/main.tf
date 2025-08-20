#############################################################
# Terraform configuration for Flask App + PostgreSQL on Azure
# Region: West Europe | PaaS-Only | Cost-Optimized | HA Ready
#############################################################

# Specify the required provider and version
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.1"
}

provider "azurerm" {
  features {}
}

#####################
# Resource Group
#####################
resource "azurerm_resource_group" "main" {
  name     = "aztek-app-rg"
  location = "westeurope"
}

#####################
# App Service Plan (Linux, PaaS, cost-optimized)
#####################
resource "azurerm_app_service_plan" "main" {
  name                = "aztek-app-service-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"    # For cost-efficiency, change to "Standard" or "PremiumV2" for more scale/HA
    size = "B1"
  }

  # Enable zone redundancy for high availability (PremiumV2 or higher required)
  # zone_redundant = true # Uncomment if you use a higher tier
}

#####################
# App Service (Flask app)
#####################
resource "azurerm_app_service" "main" {
  name                = "aztek-app-service"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.main.id

  site_config {
    linux_fx_version = "PYTHON|3.11"
    always_on        = true
    # Consider limits for scaling-out if needed
  }

  app_settings = {
    FLASK_SECRET_KEY        = var.flask_secret_key
    OPENWEATHER_API_KEY     = var.openweather_api_key
    DATABASE_URL            = "postgresql://${azurerm_postgresql_flexible_server.main.administrator_login}:${azurerm_posazurerm_postgresql_database.maintgresql_flexible_server.main.administrator_password}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${.name}?sslmode=require"
    WEBSITES_PORT           = "8000" # Or the port your Flask app listens on
  }

  # Enable Managed Identity for future enhancements (like Key Vault integration)
  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_postgresql_flexible_server.main,
    azurerm_postgresql_flexible_server_database.main
  ]
}

#####################
# PostgreSQL Flexible Server (PaaS, high-availability ready)
#####################
resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "aztekpgserver"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  version                = "15"
  storage_mb             = 32768    # 32 GB (minimum)
  administrator_login    = var.pg_admin_user
  administrator_password = var.pg_admin_password
  sku_name               = "B_Standard_B1ms" # Cost effective, HA: Use Zone Redundant for prod

  # For HA, enable zone redundancy in production
  # high_availability {
  #   mode = "ZoneRedundant"
  # }
  # Uncomment above and switch to a higher SKU for true HA

  # Allow connection from App Service outbound IPs (wide open for demo)
  authentication {
    active_directory_auth_enabled = false
    password_auth_enabled         = true
  }

  public_network_access_enabled = true
  # In production, restrict to only App Service outbound IPs or use private endpoints
  # See: azurerm_app_service.main.outbound_ip_addresses
}

resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = "aztekdb"
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

#####################
# (Optional) Azure Front Door for Global Low-Latency Access
#####################
resource "azurerm_frontdoor" "main" {
  name                                         = "aztek-frontdoor"
  resource_group_name                          = azurerm_resource_group.main.name
  enforce_backend_pools_certificate_name_check = false

  frontend_endpoint {
    name                              = "aztek-fd-endpoint"
    host_name                         = "${azurerm_frontdoor.main.name}.azurefd.net"
    session_affinity_enabled          = false
    session_affinity_ttl_seconds      = 0
    web_application_firewall_policy_link_id = null
  }

  backend_pool {
    name = "appservice-backend"
    backend {
      host_header = azurerm_app_service.main.default_site_hostname
      address     = azurerm_app_service.main.default_site_hostname
      http_port   = 80
      https_port  = 443
      enabled     = true
      priority    = 1
      weight      = 50
    }
    load_balancing_name  = "loadbalancer"
    health_probe_name    = "healthprobe"
  }

  backend_pool_health_probe {
    name                = "healthprobe"
    protocol            = "Https"
    path                = "/"
    interval_in_seconds = 30
  }

  backend_pool_load_balancing {
    name                            = "loadbalancer"
    sample_size                     = 4
    successful_samples_required      = 2
    additional_latency_milliseconds = 0
  }

  routing_rule {
    name               = "appservice-rule"
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["aztek-fd-endpoint"]
    forwarding_configuration {
      forwarding_protocol = "HttpsOnly"
      backend_pool_name   = "appservice-backend"
    }
  }

  depends_on = [
    azurerm_app_service.main
  ]
}

#####################
# Outputs
#####################
output "app_service_url" {
  description = "URL for the Flask web application"
  value       = azurerm_app_service.main.default_site_hostname
}

output "frontdoor_url" {
  description = "Global Front Door endpoint for the app"
  value       = "${azurerm_frontdoor.main.frontend_endpoint[0].host_name}"
}

#####################
# Variables (for secrets and keys)
#####################
variable "flask_secret_key" {
  description = "Flask SECRET_KEY for session security"
  type        = string
  sensitive   = true
}

variable "openweather_api_key" {
  description = "API key for OpenWeather"
  type        = string
  sensitive   = true
}

variable "pg_admin_user" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "pgadminuser"
}

variable "pg_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

#####################
# Notes:
# - For production, use PremiumV2 or higher for App Service Plan and enable zone redundancy.
# - Lock down PostgreSQL public access and consider using Private Endpoints.
# - For CI/CD, consider using Azure DevOps or GitHub Actions to deploy this configuration.
# - Store all secrets in Azure Key Vault and reference them in Terraform for true security.
# - To deploy: terraform init && terraform apply -var="flask_secret_key=yourkey" -var="openweather_api_key=yourkey" -var="pg_admin_password=yourpassword"
#####################