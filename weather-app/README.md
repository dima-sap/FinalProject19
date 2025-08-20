# Aztek Weather App

A Flask web application to fetch and display the next 5 weather forecasts for a city, save queries to a PostgreSQL database, and prepare for seamless Azure deployment.

<img width="594" height="805" alt="image" src="https://github.com/user-attachments/assets/e949bd71-250b-4017-b2cb-f50f30cf6ad9" />


---

## Features

- User inputs name and city, fetches weather from **OpenWeatherMap**.
- Displays the next 5 forecasts in a table.
- Saves queries to a **PostgreSQL** database with user, city, weather, and timestamp.
- Uses environment variables for all secrets and configuration.
- Ready for Azure App Service + Azure PostgreSQL deployment.

---

## Local Setup

1. **Clone the repository**

   ```sh
   git clone https://github.com/aztek-test-cloud/aztek-weather-app.git
   cd aztek-weather-app
   ```

2. **Create and activate a virtual environment**

   ```sh
   python3 -m venv venv
   source venv/bin/activate   # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**

   ```sh
   pip install -r requirements.txt
   ```

4. **Environment variables**

   - Copy `.env.example` to `.env` and fill in:
     - `OPENWEATHER_API_KEY` (get from [OpenWeatherMap](https://openweathermap.org/appid))
     - `DATABASE_URL` (your local or remote PostgreSQL connection string)
     - `FLASK_SECRET_KEY` (any random string)

   ```sh
   cp .env.example .env
   # Edit .env with your details
   ```

5. **Run the app**

   ```sh
   export FLASK_APP=app.py
   export FLASK_ENV=development
   flask run
   ```

   Or, if using `.env` and `python-dotenv`, just:

   ```sh
   flask run
   ```

   The app will be available at [http://localhost:5000](http://localhost:5000).

---

## Deployment to Azure

1. **Provision Azure Resources**
   - Azure App Service (Linux, Python stack)
   - Azure Database for PostgreSQL

2. **Configure App Service Application Settings:**
   - Set `DATABASE_URL`, `OPENWEATHER_API_KEY`, and `FLASK_SECRET_KEY` in the Azure portal under your App Service’s Configuration > Application settings.

3. **Update `DATABASE_URL`**  
   Use the connection string for your Azure PostgreSQL database.

4. **Deploy the code**  
   - Push to your Azure App Service via GitHub Actions, local Git, or Azure CLI.

5. **Production WSGI Server**  
   - Use Gunicorn in production (Azure):
     ```sh
     gunicorn app:app
     ```

---

## Notes

- The database table is auto-created on first run if it does not exist.
- All config is via environment variables for local and Azure compatibility.
- For secrets, never commit `.env` or credentials—use `.gitignore`.

---

## Example `.env`

See `.env.example` for the required environment variables.

---

## License

MIT
