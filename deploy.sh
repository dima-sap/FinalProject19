#!/bin/bash

# Azure deployment script for Python Flask app
echo "Starting Azure deployment..."

# Install Python dependencies
echo "Installing Python dependencies..."
python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt

echo "Deployment completed successfully!"