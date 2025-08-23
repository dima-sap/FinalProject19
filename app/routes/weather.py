"""
Weather routes for the Weather Forecast App
Handles weather fetching and saving operations
"""
import json
from datetime import datetime
from flask import Blueprint, render_template, request, redirect, url_for, flash, current_app
from ..models import WeatherLog, db
from ..utils import fetch_weather_data, validate_weather_data

weather_bp = Blueprint('weather', __name__)


@weather_bp.route("/get_weather", methods=["POST"])
def get_weather():
    """Fetch weather data and display results"""
    user_name = (request.form.get("user_name") or "").strip()
    city = (request.form.get("city") or "").strip()
    
    if not user_name or not city:
        flash("Please enter both your name and a city.", "error")
        return redirect(url_for("main.index"))
    
    # Fetch weather data using utility function
    forecasts, error = fetch_weather_data(
        city, 
        timeout=current_app.config.get('WEATHER_API_TIMEOUT', 10)
    )
    
    if error:
        flash(f"Weather Error: {error}", "error")
        return redirect(url_for("main.index"))
    
    if not forecasts:
        flash("No forecast data available.", "error")
        return redirect(url_for("main.index"))
    
    # Get recent forecasts for this user
    user_recent = []
    try:
        user_recent = WeatherLog.get_user_forecasts(
            user_name,
            limit=current_app.config.get('USER_FORECAST_LIMIT', 5)
        )
    except Exception as e:
        current_app.logger.error(f"Error fetching user recent forecasts: {e}")
    
    return render_template(
        "index.html",
        user_name=user_name,
        city=city,
        forecasts=forecasts,
        user_recent_forecasts=user_recent,
        openweather_api_key=current_app.config.get('OPENWEATHER_API_KEY') 
                          if current_app.config.get('EXPOSE_API_KEY_IN_HTML') 
                          else ""
    )


@weather_bp.route("/save_forecast", methods=["POST"])
def save_forecast():
    """Save weather forecast data to the database"""
    user_name = (request.form.get("user_name") or "").strip()
    city = (request.form.get("city") or "").strip()
    forecasts_data = request.form.get("forecasts_data")

    # Validate input
    if not user_name or not city:
        flash("User name and city are required.", "error")
        return redirect(url_for("main.index"))

    if not forecasts_data:
        flash("No forecast data to save. Fetch weather first.", "error")
        return redirect(url_for("main.index"))

    # Parse and validate JSON data
    try:
        weather_data = json.loads(forecasts_data)
    except json.JSONDecodeError:
        flash("Invalid forecast data format.", "error")
        return redirect(url_for("main.index"))

    # Validate weather data structure
    if not validate_weather_data(weather_data):
        flash("Invalid forecast data structure.", "error")
        return redirect(url_for("main.index"))

    # Save to database
    try:
        weather_log = WeatherLog(
            user_name=user_name,
            city=city,
            weather_data=weather_data,
            timestamp=datetime.utcnow()
        )
        
        if weather_log.save():
            flash(f"Weather forecast for {city} saved successfully!", "success")
            current_app.logger.info(f"✅ Saved: user={user_name} city={city}")
        else:
            flash("Failed to save forecast: database error.", "error")
            
    except Exception as e:
        current_app.logger.error(f"Unexpected error saving forecast: {e}")
        flash("Failed to save forecast: unexpected error.", "error")

    return redirect(url_for("main.index"))
