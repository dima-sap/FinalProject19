# weather-app

<img width="894" height="722" alt="Screenshot 2025-08-19 105721" src="https://github.com/user-attachments/assets/4cbc6a77-5ecf-43b7-b954-98809844579d" />

A full-stack Flask web application for weather forecasting, featuring a modern user interface, secure passwordless authentication, and seamless integration with Azure PostgreSQL for scalable data storage. The app is cloud-ready, leveraging Azure services and infrastructure-as-code (Terraform) for robust, automated deployment and management.

<img width="1293" height="564" alt="image" src="https://github.com/user-attachments/assets/d4f426d4-1e47-4748-b6ce-caf49ea717cc" />

<img width="1103" height="833" alt="image" src="https://github.com/user-attachments/assets/ad4ccf94-5cd8-4892-8889-cc012bb7971d" />

## Setup

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Azure PostgreSQL Configuration

This application uses Azure PostgreSQL with passwordless authentication. Set up the following environment variables:

#### Required Environment Variables
```bash
# Azure PostgreSQL Configuration
export DBHOST=your-server-name.postgres.database.azure.com
export DBNAME=postgres
export DBUSER=your-azure-username@domain.com
export SSLMODE=require

# Flask Configuration
export FLASK_SECRET_KEY=your-secret-key-change-in-production
export FLASK_ENV=development

# Weather API
export OPENWEATHER_API_KEY=your-openweather-api-key
```

#### Optional Environment Variables
```bash
# For password-based authentication (fallback)
export DBPASSWORD=your-database-password

# Override database URL completely
export DATABASE_URL=postgresql://user:password@host:port/database
```

### 3. Azure Authentication Setup

For passwordless authentication, you need to:

1. **Sign in to Azure CLI:**
   ```bash
   az login
   ```

2. **Configure Microsoft Entra integration** on your Azure PostgreSQL server
3. **Add your Azure account as a Microsoft Entra administrator** on the server

### 4. Run the Application
```bash
python app.py
```

The application will:
- Try to connect to Azure PostgreSQL using passwordless authentication
- Fall back to password-based authentication if needed
- Fall back to SQLite for development if Azure connection fails

### Installation

```bash
git clone https://github.com/BarSagiv/aztek-app.git
cd aztek-app
# Set up backend (Python)
pip install -r requirements.txt

# Set up infrastructure (Terraform)
cd terraform/
terraform init
terraform apply
```

> Adjust these commands as appropriate to your actual project structure.

### Running the App

```bash
# Example for backend
python main.py

# Or via Docker (if supported)
docker compose up
```

### Environment Variables

Create a `.env` file in the root directory and set the following variables:

```
EXAMPLE_ENV=your_value
```


## Architecture

### Database Connection
The application uses a smart connection strategy:

1. **Primary**: Azure PostgreSQL with passwordless authentication (Microsoft Entra ID)
2. **Fallback**: Azure PostgreSQL with password authentication
3. **Development**: SQLite database

### Files
- `get_conn.py`: Azure PostgreSQL connection helper with passwordless authentication
- `config.py`: Configuration with Azure PostgreSQL integration
- `models.py`: SQLAlchemy database models
- `app.py`: Flask application factory

## Azure plan

<img width="753" height="652" alt="image" src="https://github.com/user-attachments/assets/be8ca211-84c2-4b4d-a978-a7c48e0ac28b" />
