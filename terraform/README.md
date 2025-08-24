# Terraform Infrastructure for Aztek Weather App

This Terraform configuration creates the complete Azure infrastructure for the Aztek Weather Flask application.

## Infrastructure Overview

The Terraform configuration creates:

- **Resource Group**: Container for all resources
- **Virtual Network**: With subnets for App Service and Database
- **PostgreSQL Flexible Server**: With private endpoint (no public access)
- **Private DNS Zone**: For PostgreSQL private endpoint resolution
- **App Service Plan**: Linux-based hosting plan
- **App Service**: Python Flask application with VNet integration
- **Front Door**: CDN and global load balancer (optional)

## Prerequisites

### 1. Install Required Tools

```bash
# Install Terraform
brew install terraform

# Install Azure CLI
brew install azure-cli

# Verify installations
terraform --version
az --version
```

### 2. Azure Authentication

```bash
# Login to Azure
az login

# Set your subscription (if you have multiple)
az account set --subscription "your-subscription-id"

# Verify current subscription
az account show
```

### 3. Get Required API Keys

- **OpenWeather API Key**: Get from [openweathermap.org](https://openweathermap.org/api)

## Setup Instructions

### 1. Prepare Configuration

```bash
# Navigate to terraform directory
cd terraform

# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
nano terraform.tfvars
```

### 2. Required Variables to Update

Edit `terraform.tfvars` and update these REQUIRED values:

```hcl
# CHANGE THESE - REQUIRED!
db_admin_password   = "YourSecurePassword123!"
flask_secret_key    = "your-super-secret-flask-key-change-this"  
openweather_api_key = "your-openweather-api-key"

# Optionally customize these
resource_group_name = "aztek-app-rg"
location           = "North Europe"
project_name       = "aztek"
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform (downloads providers)
terraform init

# Review the planned changes
terraform plan

# Apply the configuration
terraform apply
```

**Note**: The first deployment takes 10-15 minutes.

## Deployment Commands

### Initial Deployment
```bash
terraform init
terraform plan
terraform apply
```

### Update Infrastructure
```bash
terraform plan
terraform apply
```

### Destroy Infrastructure
```bash
terraform destroy
```

### Check Current State
```bash
terraform show
terraform output
```

## Important Outputs

After deployment, Terraform will output important information:

```bash
# Get all outputs
terraform output

# Get specific outputs
terraform output app_service_url
terraform output front_door_url
terraform output postgresql_server_fqdn
```

## App Deployment

After infrastructure is created, deploy your Flask app:

### Option 1: Azure CLI Deployment

```bash
# Navigate back to app directory
cd ../

# Create deployment package
zip -r app.zip . -x "terraform/*" ".git/*" "*.pyc" "__pycache__/*"

# Deploy to App Service
az webapp deployment source config-zip \
  --resource-group aztek-app-rg \
  --name aztek-flask-app \
  --src app.zip
```

### Option 2: GitHub Actions (Recommended)

Set up automated deployment using the existing GitHub Actions workflow in `.github/workflows/azure-webapps-python.yml`.

## Configuration Details

### Networking Architecture

```
Internet → Front Door → App Service → VNet Integration → Private Endpoint → PostgreSQL
```

- **Public Access**: Only through Front Door (if enabled) or directly to App Service
- **Database Access**: Private only, through VNet private endpoint
- **SSL/TLS**: Enforced end-to-end

### Security Features

- ✅ PostgreSQL has **no public access** (private endpoint only)
- ✅ SSL/TLS enforced for all connections
- ✅ VNet isolation for database traffic
- ✅ Private DNS resolution within VNet
- ✅ App Service integrated with VNet

### Cost Optimization

The default configuration uses cost-effective tiers:

- **App Service Plan**: B1 (Basic) - ~$13/month
- **PostgreSQL**: B_Standard_B1ms (Burstable) - ~$12/month  
- **Front Door**: Standard tier - pay-per-use
- **VNet/Private Endpoint**: ~$7/month

**Estimated monthly cost**: ~$35-50 USD

## Environment Variables

The Terraform automatically configures these environment variables in your App Service:

```bash
# Database Configuration
DBHOST=your-server.postgres.database.azure.com
DBNAME=postgres
DBUSER=pgadminuser
DBPASSWORD=your-password
SSLMODE=require

# Flask Configuration  
FLASK_SECRET_KEY=your-secret-key
FLASK_ENV=production

# API Configuration
OPENWEATHER_API_KEY=your-api-key
```

## Troubleshooting

### Common Issues

1. **"Resource already exists"**
   ```bash
   # Import existing resource (example)
   terraform import azurerm_resource_group.main /subscriptions/xxx/resourceGroups/aztek-app-rg
   ```

2. **PostgreSQL connection issues**
   - Verify private endpoint is "Approved"
   - Check VNet integration on App Service
   - Verify private DNS zone configuration

3. **App Service deployment issues**  
   - Check App Service logs in Azure portal
   - Verify environment variables are set
   - Check Python version compatibility

### Debugging Commands

```bash
# Check Terraform state
terraform state list
terraform state show azurerm_resource_group.main

# Validate configuration
terraform validate
terraform fmt

# Check Azure resources
az group show --name aztek-app-rg
az webapp log tail --name aztek-flask-app --resource-group aztek-app-rg
```

## Customization

### Scaling Options

To scale up for production:

```hcl
# In terraform.tfvars
app_service_sku     = "S1"              # Standard tier
postgres_sku_name   = "GP_Standard_D2s" # General Purpose
postgres_storage_mb = 65536             # 64GB storage
```

### Multi-Environment Setup

Create separate `.tfvars` files for different environments:

```bash
# Development
terraform apply -var-file="dev.tfvars"

# Production  
terraform apply -var-file="prod.tfvars"
```

## Security Best Practices

1. **Never commit `terraform.tfvars`** to version control
2. **Use strong passwords** for database admin
3. **Rotate secrets regularly**
4. **Monitor App Service logs** for security issues
5. **Enable Azure Security Center** recommendations

## Support

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [Azure PostgreSQL Documentation](https://docs.microsoft.com/en-us/azure/postgresql/)

---

**Next Steps**: After infrastructure deployment, configure your CI/CD pipeline for automated app deployments!
