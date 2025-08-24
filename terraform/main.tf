# Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Create Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-vnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Subnet for App Service VNet Integration
resource "azurerm_subnet" "app_service" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.app_subnet_address_prefix]

  delegation {
    name = "app-service-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Subnet for Database Private Endpoint
resource "azurerm_subnet" "database" {
  name                 = "db-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.db_subnet_address_prefix]

  private_endpoint_network_policies = "Disabled"
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "${var.project_name}pgserver"
  resource_group_name    = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  version               = var.postgres_version
  administrator_login    = var.db_admin_username
  administrator_password = var.db_admin_password
  
  sku_name = var.postgres_sku_name
  storage_mb = var.postgres_storage_mb
  
  backup_retention_days = 7
  
  # Disable public access - we'll use private endpoint
  public_network_access_enabled = false

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# PostgreSQL Database
resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = "postgres"
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Private DNS Zone for PostgreSQL
resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "${var.project_name}-postgres-dns-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Private Endpoint for PostgreSQL
resource "azurerm_private_endpoint" "postgres" {
  name                = "${var.project_name}-db-endpoint"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.database.id

  private_service_connection {
    name                           = "${var.project_name}-db-connection"
    private_connection_resource_id = azurerm_postgresql_flexible_server.main.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "postgres-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.postgres.id]
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "${var.project_name}-flask-app-plan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# App Service
resource "azurerm_linux_web_app" "main" {
  name                = "${var.project_name}-flask-app"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    application_stack {
      python_version = "3.11"
    }
    
    # Enable VNet integration
    vnet_route_all_enabled = true
  }

  app_settings = {
    # Database Configuration
    "DBHOST"     = azurerm_postgresql_flexible_server.main.fqdn
    "DBNAME"     = azurerm_postgresql_flexible_server_database.main.name
    "DBUSER"     = var.db_admin_username
    "DBPASSWORD" = var.db_admin_password
    "SSLMODE"    = "require"
    
    # Flask Configuration
    "FLASK_SECRET_KEY" = var.flask_secret_key
    "FLASK_ENV"        = var.environment == "prod" ? "production" : "development"
    
    # API Configuration
    "OPENWEATHER_API_KEY" = var.openweather_api_key
    
    # Python Configuration
    "PYTHONPATH" = "/home/site/wwwroot"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# VNet Integration for App Service
resource "azurerm_app_service_virtual_network_swift_connection" "main" {
  app_service_id = azurerm_linux_web_app.main.id
  subnet_id      = azurerm_subnet.app_service.id
}
