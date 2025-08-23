"""
Weather Forecast App - Main Application Factory
"""
import os
from flask import Flask
from config import getConfig
from models import db
from routes import blueprints


def create_app(config_name=None):
    """
    Application factory function that creates and configures the Flask app
    
    Args:
        config_name (str): Configuration environment name
        
    Returns:
        Flask: Configured Flask application instance
    """
    if config_name is None:
        config_name = os.environ.get('FLASK_ENV', 'default')
    
    # Create Flask application
    app = Flask(__name__)
    
    # Load configuration
    config_class = getConfig(config_name)
    app.config.from_object(config_class)
    config_class.init_app(app)
    
    # Initialize extensions
    db.init_app(app)
    
    # Register blueprints
    for blueprint, options in blueprints:
        app.register_blueprint(blueprint, **options)
    
    # Create database tables
    with app.app_context():
        try:
            db.create_all()
            app.logger.info("✅ Database ready")
            print("🚀 Database initialized successfully")
        except Exception as e:
            app.logger.error(f"⚠️  Database init failed: {e}")
            print(f"❌ Database initialization failed: {e}")
    
    return app


def create_cli_app():
    """Create app for CLI commands"""
    return create_app('development')

# ------------------------------
# Entrypoint
# ------------------------------
if __name__ == "__main__":
    app = create_app()
    port = int(os.environ.get("PORT", 8000))
    app.run(host="0.0.0.0", port=port, debug=True)
