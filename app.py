import os
import json
import requests
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy

# --- Flask app setup ---
app = Flask(__name__)
# Secret key from environment variable (use fallback 'dev' only locally)
app.secret_key = os.environ.get('FLASK_SECRET_KEY', 'dev')

# --- Database setup ---
# DATABASE_URL from environment (Azure secret), fallback to local SQLite
DATABASE_URL = os.environ.get('DATABASE_URL', 'sqlite:///weather.db')
app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URL
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# --- OpenWeather API key ---
OPENWEATHER_API_KEY = os.environ.get('OPENWEATHER_API_KEY')
if not OPENWEATHER_API_KEY:
    print("Warning: OPENWEATHER_API_KEY not set. App will fail until you set it in environment variables.")

# --- Database model ---
class WeatherLog(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_name = db.Column(db.String(100), nullable=False)
    city = db.Column(db.String(100), nullable=False)
    weather_data = db.Column(db.JSON, nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

# Ensure tables are created
with app.app_context():
    db.create_all()

# --- Fetch weather function ---
def fetch_weather(city):
    url = f"https://api.openweathermap.org/data/2.5/forecast?q={city}&appid={OPENWEATHER_API_KEY}&units=metric"
    try:
        resp = requests.get(url, timeout=10)
        data = resp.json()
        if resp.status_code != 200 or data.get('cod') != '200':
            msg = data.get('message', 'Unknown error occurred.')
            return None, f"City not found or API error: {msg}"
        return data['list'][:5], None
    except Exception as e:
        return None, f"Error contacting weather service: {e}"

# --- Flask routes ---
@app.route('/', methods=['GET', 'POST'])
def index():
    forecasts = None
    error = None
    user_name = ""
    city = ""
    saved_forecasts = []

    if request.method == 'POST':
        if 'get_weather' in request.form:
            user_name = request.form.get('user_name', '').strip()
            city = request.form.get('city', '').strip()
            if not user_name or not city:
                error = "Please enter both your name and a city."
            else:
                forecasts, error = fetch_weather(city)
        elif 'save_forecast' in request.form:
            user_name = request.form.get('user_name', '').strip()
            city = request.form.get('city', '').strip()
            forecasts_data = request.form.get('forecasts_data')
            if not forecasts_data:
                flash("No forecast data to save.", "error")
            else:
                log = WeatherLog(
                    user_name=user_name,
                    city=city,
                    weather_data=json.loads(forecasts_data),
                    timestamp=datetime.utcnow()
                )
                db.session.add(log)
                db.session.commit()
                flash("Forecast saved successfully!", "success")
                return redirect(url_for('index'))

    saved_forecasts = WeatherLog.query.order_by(WeatherLog.timestamp.desc()).limit(10).all()

    return render_template(
        'index.html',
        forecasts=forecasts,
        error=error,
        user_name=user_name,
        city=city,
        saved_forecasts=saved_forecasts
    )

# --- Run app locally ---
if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8000))
    app.run(debug=True, host='0.0.0.0', port=port)

# test