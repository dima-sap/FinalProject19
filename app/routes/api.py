"""
API routes for the Weather Forecast App
Handles JSON API endpoints
"""
from flask import Blueprint, request, jsonify, current_app
from models import WeatherLog
from utils import fetch_weather_data

api_bp = Blueprint('api', __name__)


@api_bp.route("/recent", methods=["GET"])
def recent_for_name():
    """
    Returns JSON of the 5 most recent saves for a given user_name.
    GET /api/recent?user_name=Alice
    """
    user_name = (request.args.get("user_name") or "").strip()
    if not user_name:
        return jsonify([])

    try:
        forecasts = WeatherLog.get_user_forecasts(
            user_name,
            limit=current_app.config.get('USER_FORECAST_LIMIT', 5)
        )
        return jsonify([forecast.to_dict() for forecast in forecasts])
    except Exception as e:
        current_app.logger.error(f"Recent fetch error: {e}")
        return jsonify({"error": "Internal server error"}), 500


@api_bp.route("/weather", methods=["GET"])
def get_weather():
    """
    Backend API to fetch weather data securely without exposing API key to frontend.
    GET /api/weather?city=CityName
    """
    city = (request.args.get("city") or "").strip()
    if not city:
        return jsonify({"error": "City parameter is required"}), 400
    
    if not current_app.config.get('OPENWEATHER_API_KEY'):
        return jsonify({"error": "OpenWeather API key not configured"}), 500
    
    # Use utility function to fetch weather data
    forecasts, error = fetch_weather_data(
        city, 
        timeout=current_app.config.get('WEATHER_API_TIMEOUT', 10)
    )
    
    if error:
        return jsonify({"error": error}), 400
    
    if not forecasts:
        return jsonify({"error": "No forecast data available"}), 404
    
    return jsonify({"list": forecasts})


@api_bp.route("/users", methods=["GET"])
def get_users():
    """
    Get list of all users who have saved forecasts
    GET /api/users
    """
    try:
        # Get distinct user names from the database
        users = (
            WeatherLog.query
            .with_entities(WeatherLog.user_name)
            .distinct()
            .order_by(WeatherLog.user_name)
            .all()
        )
        
        user_list = [user[0] for user in users]
        return jsonify({"users": user_list})
        
    except Exception as e:
        current_app.logger.error(f"Error fetching users: {e}")
        return jsonify({"error": "Internal server error"}), 500


@api_bp.route("/forecasts", methods=["GET"])
def get_all_forecasts():
    """
    Get paginated list of all forecasts
    GET /api/forecasts?page=1&per_page=10
    """
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 10, type=int)
        
        # Limit per_page to prevent abuse
        per_page = min(per_page, 50)
        
        pagination = (
            WeatherLog.query
            .order_by(WeatherLog.timestamp.desc())
            .paginate(
                page=page,
                per_page=per_page,
                error_out=False
            )
        )
        
        return jsonify({
            "forecasts": [forecast.to_dict() for forecast in pagination.items],
            "total": pagination.total,
            "pages": pagination.pages,
            "current_page": page,
            "per_page": per_page,
            "has_next": pagination.has_next,
            "has_prev": pagination.has_prev
        })
        
    except Exception as e:
        current_app.logger.error(f"Error fetching forecasts: {e}")
        return jsonify({"error": "Internal server error"}), 500


@api_bp.errorhandler(404)
def api_not_found(error):
    """Handle 404 errors for API routes"""
    return jsonify({"error": "API endpoint not found"}), 404


@api_bp.errorhandler(500)
def api_internal_error(error):
    """Handle 500 errors for API routes"""
    return jsonify({"error": "Internal server error"}), 500
