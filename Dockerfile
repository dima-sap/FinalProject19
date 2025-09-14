# Use the official Python image as a base (choose a slim variant for smaller image)
FROM python:3.11-slim

# Set working directory inside the container
WORKDIR /app

# Install system dependencies (if required, e.g., for psycopg2)
RUN apt-get update && \
    apt-get install -y build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements.txt first to leverage Docker layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Set environment variables for Flask
ENV FLASK_APP=app.py
ENV FLASK_ENV=production

# Expose the port Flask runs on
EXPOSE 5000

# Optionally, create a non-root user for security (uncomment if desired)
# RUN useradd -m appuser && chown -R appuser /app
# USER appuser

# Start the Flask app using gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
