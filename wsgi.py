""
WSGI entry point for Azure App Service
""
print("a")
from app import create_app
import os
app = create_app()

if __name__ == "__main__":
    print("hello")
    port = int(os.environ.get("PORT", 8000))
    app.run(host="0.0.0.0", port=port, debug=True)
