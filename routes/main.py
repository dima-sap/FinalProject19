"""
Main routes for the Weather Forecast App
Handles the main pages and navigation
"""
from flask import Blueprint, render_template, current_app, flash, redirect, url_for
from ..models import WeatherLog

main_bp = Blueprint('main', __name__)


@main_bp.route("/")
def index():
    """Main page - displays the weather form and recent forecasts"""
    # Get recent forecasts to display on main page
    recent_forecasts = []
    try:
        recent_forecasts = WeatherLog.get_recent_forecasts(
            limit=current_app.config.get('ITEMS_PER_PAGE', 10)
        )
    except Exception as e:
        current_app.logger.error(f"Error fetching recent forecasts: {e}")
    
    return render_template(
        "index.html",
        saved_forecasts=recent_forecasts,
        openweather_api_key=current_app.config.get('OPENWEATHER_API_KEY') 
                          if current_app.config.get('EXPOSE_API_KEY_IN_HTML') 
                          else ""
    )


@main_bp.route("/user_forecasts/<user_name>")
def user_forecasts(user_name):
    """Display the most recent forecasts for a specific user"""
    user_name = user_name.strip()
    if not user_name:
        flash("Invalid user name.", "error")
        return redirect(url_for("main.index"))
    
    try:
        forecasts = WeatherLog.get_user_forecasts(
            user_name, 
            limit=current_app.config.get('USER_FORECAST_LIMIT', 5)
        )
        
        return render_template(
            "user_forecasts.html",
            user_name=user_name,
            forecasts=forecasts
        )
    except Exception as e:
        current_app.logger.error(f"Error fetching forecasts for {user_name}: {e}")
        flash("Error fetching user forecasts.", "error")
        return redirect(url_for("main.index"))


@main_bp.route("/healthz")
def healthz():
    """Health check endpoint"""
    from datetime import datetime
    return {"status": "ok", "time": datetime.utcnow().isoformat()}
