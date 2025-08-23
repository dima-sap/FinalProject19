#!/usr/bin/env python3
"""
Entry point for running the Weather Forecast App
"""
import os
from app import create_app

# Create the Flask application
app = create_app()

if __name__ == '__main__':
    # Development server configuration
    host = os.environ.get('HOST', '0.0.0.0')
    port = int(os.environ.get('PORT', 8000))
    debug = os.environ.get('FLASK_ENV') == 'development'
    
    print(f"🌦️  Starting Weather Forecast App on http://{host}:{port}")
    print(f"🔧 Environment: {os.environ.get('FLASK_ENV', 'development')}")
    print(f"🐛 Debug mode: {debug}")
    
    app.run(
        host=host,
        port=port,
        debug=debug
    )
