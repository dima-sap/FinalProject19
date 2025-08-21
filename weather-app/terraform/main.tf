#############################################################
# Terraform configuration for Flask App + PostgreSQL on Azure
# Region: North Europe | PaaS-Only | Cost-Optimized | HA Ready
#############################################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75.0"
    }
  }
  required_version = ">= 1.3"
}

provider "azurerm" {
  features {}
}

#####################
# Resource Group
#####################
resource "azurerm_resource_group" "main" {
  name     = "aztek-app-rg"
  location = "northeurope"
}

#####################
# App Service Plan (Linux, PaaS, cost-optimized)
#####################
resource "azurerm_service_plan" "main" {
  name                = "aztek-flask-app-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "B1"
}

#####################
# App Service (Flask app)
#####################
resource "azurerm_app_service" "main" {
  name                = "aztek-flask-app"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_service_plan.main.id   # <-- fixed

  site_config {
    linux_fx_version = "PYTHON|3.11"
    always_on        = true
  }

  app_settings = {
    FLASK_SECRET_KEY    = var.flask_secret_key
    OPENWEATHER_API_KEY = var.openweather_api_key
    DATABASE_URL        = "postgresql://${azurerm_postgresql_flexible_server.main.administrator_login}:${azurerm_postgresql_flexible_server.main.administrator_password}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${azurerm_postgresql_flexible_server_database.main.name}?sslmode=require"
    WEBSITES_PORT       = "8000"
  }

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

  authentication {
    active_directory_auth_enabled = false
    password_auth_enabled         = true
  }

}

resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = "aztekdb"
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

#####################
# Outputs
#####################
output "app_service_url" {
  description = "URL for the Flask web application"
  value       = azurerm_app_service.main.default_site_hostname
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