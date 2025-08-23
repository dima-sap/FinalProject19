# Weather Forecast App - Architecture

## Project Structure

The application has been refactored to follow Flask best practices with a modular, scalable architecture:

```
weather-app/
├── app.py                 # Application factory
├── run.py                 # Application entry point
├── config.py              # Configuration management
├── models.py              # Database models
├── utils.py               # Utility functions
├── routes/                # Route blueprints
│   ├── __init__.py        # Blueprint registration
│   ├── main.py            # Main page routes
│   ├── weather.py         # Weather functionality routes
│   └── api.py             # JSON API routes
├── templates/             # Jinja2 templates
│   ├── index.html         # Main page
│   └── user_forecasts.html
├── static/                # CSS, JS, images
│   └── style.css
├── requirements.txt       # Python dependencies
└── instance/              # Instance-specific files
```

## Architecture Components

### 1. Application Factory Pattern (`app.py`)
- Uses the factory pattern for creating Flask app instances
- Supports multiple configurations (development, production, testing)
- Centralizes app initialization and configuration

### 2. Configuration Management (`config.py`)
- Environment-based configuration classes
- Secure handling of API keys and database URLs
- Separate settings for development, production, and testing

### 3. Database Models (`models.py`)
- SQLAlchemy models with helper methods
- Clean separation of data layer
- Built-in query methods for common operations

### 4. Utility Functions (`utils.py`)
- Weather API integration
- Data validation functions
- Helper functions for formatting and processing

### 5. Blueprint Architecture (`routes/`)
- **main.py**: Core page routes (index, user profiles)
- **weather.py**: Weather fetching and saving functionality
- **api.py**: RESTful JSON API endpoints
- **__init__.py**: Centralized blueprint registration

## Benefits of This Structure

### 🏗️ **Modularity**
- Each component has a single responsibility
- Easy to locate and modify specific functionality
- Better code organization and maintainability

### 🔧 **Scalability**
- Easy to add new features as separate blueprints
- Configuration can be environment-specific
- Database models can be extended without affecting routes

### 🧪 **Testability**
- Application factory allows easy testing with different configs
- Routes can be tested independently
- Utility functions are easily unit testable

### 🛡️ **Security**
- Configuration properly handles sensitive data
- API keys are centrally managed
- Environment-based security settings

### 📦 **Deployment**
- Easy to deploy with different configurations
- Clear separation between code and configuration
- Production-ready logging and error handling

## Running the Application

### Development
```bash
python run.py
```

### Production
```bash
export FLASK_ENV=production
python run.py
```

### With Gunicorn
```bash
gunicorn "app:create_app()" --bind 0.0.0.0:8000
```

## API Endpoints

### Web Routes
- `GET /` - Main page with weather form
- `POST /get_weather` - Fetch and display weather
- `POST /save_forecast` - Save forecast to database
- `GET /user_forecasts/<username>` - User's forecast history

### JSON API Routes
- `GET /api/recent?user_name=<name>` - User's recent forecasts
- `GET /api/weather?city=<city>` - Weather data for city
- `GET /api/users` - List all users
- `GET /api/forecasts` - Paginated forecast list

## Configuration

Set environment variables:
- `FLASK_ENV` - Environment (development/production)
- `OPENWEATHER_API_KEY` - Weather API key
- `DATABASE_URL` - Database connection string
- `FLASK_SECRET_KEY` - Secret key for sessions

This architecture provides a solid foundation for future enhancements and maintains high code quality standards.
