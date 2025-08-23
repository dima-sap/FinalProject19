"""
Database models for the Weather Forecast App
"""
from datetime import datetime
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


class WeatherLog(db.Model):
    """Model for storing weather forecast logs"""
    __tablename__ = "weather_logs"
    
    id = db.Column(db.Integer, primary_key=True)
    user_name = db.Column(db.String(100), nullable=False, index=True)
    city = db.Column(db.String(100), nullable=False)
    weather_data = db.Column(db.JSON, nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow, index=True)

    def __repr__(self):
        return f'<WeatherLog {self.user_name} - {self.city} at {self.timestamp}>'

    def to_dict(self):
        """Convert model instance to dictionary"""
        return {
            "id": self.id,
            "user_name": self.user_name,
            "city": self.city,
            "weather_data": self.weather_data,
            "timestamp": self.timestamp.strftime("%Y-%m-%d %H:%M"),
        }

    @classmethod
    def get_recent_forecasts(cls, limit=10):
        """Get the most recent forecasts across all users"""
        return cls.query.order_by(cls.timestamp.desc()).limit(limit).all()

    @classmethod
    def get_user_forecasts(cls, user_name, limit=5):
        """Get recent forecasts for a specific user"""
        return (
            cls.query
            .filter(cls.user_name == user_name)
            .order_by(cls.timestamp.desc())
            .limit(limit)
            .all()
        )

    def save(self):
        """Save the current instance to database"""
        try:
            db.session.add(self)
            db.session.commit()
            return True
        except Exception as e:
            db.session.rollback()
            print(f"❌ DB error: {e}")
            return False
