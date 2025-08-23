"""
Routes package for Weather Forecast App
"""
from .main import main_bp
from .weather import weather_bp
from .api import api_bp

# List of all blueprints to register
blueprints = [
    (main_bp, {}),
    (weather_bp, {}),
    (api_bp, {'url_prefix': '/api'})
]
