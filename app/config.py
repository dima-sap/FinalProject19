"""
Configuration settings for the Weather Forecast App
"""
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Azure PostgreSQL connection helper
try:
    from .get_conn import get_connection_uri
    AZURE_POSTGRES_AVAILABLE = True
except ImportError:
    AZURE_POSTGRES_AVAILABLE = False


class Config:
    """Base configuration class"""
    
    # Flask Configuration
    SECRET_KEY = os.environ.get("FLASK_SECRET_KEY")
    
    # Database Configuration
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # API Configuration
    OPENWEATHER_API_KEY = os.environ.get("OPENWEATHER_API_KEY")
    EXPOSE_API_KEY_IN_HTML = os.environ.get("EXPOSE_API_KEY_IN_HTML", "0") == "1"
    
    # Application Settings
    ITEMS_PER_PAGE = 10
    USER_FORECAST_LIMIT = 5
    WEATHER_API_TIMEOUT = 10
    
    @staticmethod
    def init_app(app):
        """Initialize app with this configuration"""
        pass


class DevelopmentConfig(Config):
    """Development configuration"""
    
    DEBUG = True
    
    # Use SQLite only when FLASK_ENV is specifically set to 'development'
    if os.environ.get('FLASK_ENV') == 'development':
        SQLALCHEMY_DATABASE_URI = "sqlite:///weather_dev.db"
        print("📝 Using SQLite for development (FLASK_ENV=development)")
    elif AZURE_POSTGRES_AVAILABLE and os.environ.get('DBHOST'):
        # Use Azure PostgreSQL with password authentication
        try:
            SQLALCHEMY_DATABASE_URI = get_connection_uri()
            print("🔑 Using Azure PostgreSQL with password authentication")
        except Exception as e:
            print(f"❌ Azure PostgreSQL connection failed: {e}")
            raise RuntimeError(f"Unable to connect to PostgreSQL database: {e}")
    else:
        # Use DATABASE_URL from environment or raise error
        SQLALCHEMY_DATABASE_URI = os.environ.get("DATABASE_URL")
        if SQLALCHEMY_DATABASE_URI:
            print("📄 Using DATABASE_URL from environment")
        else:
            raise ValueError("No database configuration found. Set DBHOST/DBUSER/DBPASSWORD for PostgreSQL or DATABASE_URL, or set FLASK_ENV=development for SQLite.")


class ProductionConfig(Config):
    """Production configuration"""
    
    DEBUG = False
    
    # Production requires Azure PostgreSQL
    if AZURE_POSTGRES_AVAILABLE and os.environ.get('DBHOST'):
        try:
            SQLALCHEMY_DATABASE_URI = get_connection_uri()
            print("🔑 Using Azure PostgreSQL with password authentication")
        except Exception as e:
            print(f"❌ PostgreSQL connection failed in production: {e}")
            raise RuntimeError(f"Unable to connect to PostgreSQL database: {e}")
    else:
        # Use DATABASE_URL from environment (for cloud deployments like Heroku)
        SQLALCHEMY_DATABASE_URI = os.environ.get("DATABASE_URL")
        if SQLALCHEMY_DATABASE_URI:
            print("📄 Using DATABASE_URL from environment")
        else:
            raise ValueError("Production requires database configuration. Set DBHOST/DBUSER/DBPASSWORD for PostgreSQL or DATABASE_URL.")
    
    @staticmethod
    def init_app(app):
        """Initialize production app"""
        Config.init_app(app)
        
        # Log to stderr in production
        import logging
        from logging import StreamHandler
        
        file_handler = StreamHandler()
        file_handler.setLevel(logging.INFO)
        app.logger.addHandler(file_handler)


class TestingConfig(Config):
    """Testing configuration"""
    
    TESTING = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"
    WTF_CSRF_ENABLED = False


# Configuration dictionary
config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}


def getConfig(flask_env=None):
    """
    Get the appropriate configuration class based on the Flask environment
    
    Args:
        flask_env (str): Flask environment name ('development', 'production', 'testing')
                        If None, uses FLASK_ENV environment variable or defaults to 'development'
    
    Returns:
        Config: Configuration class for the specified environment
    """
    if flask_env is None:
        flask_env = os.environ.get('FLASK_ENV', 'development')
    
    # Normalize environment name
    flask_env = flask_env.lower()
    
    # Return the appropriate config class, defaulting to development if not found
    return config.get(flask_env, config['default'])
