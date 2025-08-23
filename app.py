"""
WSGI entry point for Azure App Service
"""
print("a")
from app import create_app
print("b")
import os
app = create_app()

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    app.run(host="0.0.0.0", port=port, debug=True)