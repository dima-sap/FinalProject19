# Basic Configuration
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "aztek-app-rg"
}

variable "location" {
  description = "Azure location for resources"
  type        = string
  default     = "North Europe"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "aztek"
}

# App Service Configuration
variable "app_service_sku" {
  description = "SKU for the App Service Plan"
  type        = string
  default     = "B1"  # Basic tier
}

# PostgreSQL Configuration
variable "postgres_sku_name" {
  description = "SKU name for PostgreSQL Flexible Server"
  type        = string
  default     = "B_Standard_B1ms"  # Burstable tier
}

variable "postgres_storage_mb" {
  description = "Storage size in MB for PostgreSQL"
  type        = number
  default     = 32768  # 32GB
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "13"
}

# Database Configuration
variable "db_admin_username" {
  description = "Administrator username for PostgreSQL"
  type        = string
  default     = "pgadminuser"
}

variable "db_admin_password" {
  description = "Administrator password for PostgreSQL"
  type        = string
  sensitive   = true
}

# Application Configuration
variable "flask_secret_key" {
  description = "Flask secret key"
  type        = string
  sensitive   = true
}

variable "openweather_api_key" {
  description = "OpenWeather API key"
  type        = string
  sensitive   = true
}

# Network Configuration
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "app_subnet_address_prefix" {
  description = "Address prefix for app service subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "db_subnet_address_prefix" {
  description = "Address prefix for database subnet"
  type        = string
  default     = "10.0.2.0/24"
}

# Front Door Configuration
variable "enable_front_door" {
  description = "Whether to create Front Door for the app"
  type        = bool
  default     = true
}
