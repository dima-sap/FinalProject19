# 📖 AI Tools Documentation
## Tools Used

- ChatGPT (GPT-5)
- GitHub Copilot
- Claude

## Prompts Used to Develop the Roadmap and Understand the Project Approach (via ChatGPT):

- Let’s build a ROADMAP of the project in an organized way, starting with creating a Python Flask application, and from there continue through all the steps up to full deployment on Azure with automation. Suggest the steps in a logical order, including what needs to be done at each stage and the main considerations. Explain to me how to carry out all these steps step by step in a clear way so that I can present them visually.

- Let’s start with the Flask application — what should the folder structure look like? Later we’ll adjust everything related to Azure. Note that afterwards I’ll need to deploy the whole application on Azure, so it has to be suitable.

- Is this how it’s supposed to look in the GitHub repo?

Using these prompts, I understood how to approach the project and what to do at each stage. Afterwards, I created the roadmap visually.

## Prompt for the flask app (GitHub Copilot):
Create a complete Python Flask web application that will later be deployed to Azure. Follow these requirements:

1. Web Interface:
   - A form where users can input their name and a city.
   - A "Get Weather" button that fetches weather data from OpenWeatherMap API.
   - Display the next 5 forecasts in a clean and readable table on the same page.
   - Handle errors if the city is not found.

2. Database:
   - Use PostgreSQL with SQLAlchemy.
   - Save user name, city, weather data, and timestamp in a table.
   - Prepare the database connection using an environment variable (e.g., DATABASE_URL) so it can be replaced with Azure PostgreSQL later.
   - Include code to automatically create the table if it does not exist.

3. Project Structure:
   - app.py for the main Flask app.
   - templates/index.html for the HTML page.
   - static/style.css for optional styling.
   - Configurable API key for OpenWeatherMap using an environment variable.

4. Azure-readiness:
   - Use environment variables for all secrets (API key, DB URL).
   - Clean, modular, well-commented code.
   - Include instructions in comments on how to run locally and how to prepare for deployment to Azure App Service with Azure PostgreSQL.

5. Output:
   - Provide the complete app.py, templates/index.html, and optionally static/style.css.
   - Include example .env file format with placeholders for API key and DB URL.

## Prompt to test if the flask app works (ChatGPT):

Explain step by step how to check if my Python app works in VS Code, including how to create a test file, run it in the integrated terminal, and confirm that everything is set up correctly


I'm in step 2 in the road map. Do I need to change the code on github to be without sqlite?

👉 Short answer: No, you don’t have to remove SQLite from the code on GitHub.
Here’s why:
For local development: keeping sqlite:///weather.db is super convenient — you don’t need to run a database server every time you test.
For production on Azure: you’ll set the DATABASE_URL environment variable to point to your Azure PostgreSQL connection string.
✅ Best practice for GitHub:
Keep both options in the code (don’t hardcode Postgres).


## OIDC / GitHub Actions

Step-by-step summary of what we did in this chat:

1. Set up OIDC GitHub → Azure:

- Registered an app in Microsoft Entra ID

- Created a federated credential for GitHub Actions

- Retrieved AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID

2. Configured GitHub Actions CI/CD:

- Used azure/login with OIDC instead of secrets

- Fixed warnings about deprecated set-output

- Encountered missing requirements.txt

3. Deployed Flask app to Azure Web App:

- Deployment worked but no content showed up

- Checked deployment logs in App Service → Deployment Center

- Identified missing code / slot mismatch issue

4. Fixed API key issue:

- Added OpenWeatherMap API key as an App Setting in Azure Web App → Configuration

- App still threw 401 errors → checked env variable handling


## Database

<img width="915" height="237" alt="image" src="https://github.com/user-attachments/assets/3c94cf7a-3b88-4b22-b9e2-a94ea5ee05f2" />


<img width="544" height="202" alt="image" src="https://github.com/user-attachments/assets/c003ce78-d6d6-467f-8071-19d09276f226" />


## How the Project Evolved: Step-by-Step Overview by GitHub Copilot

1. Initialized a Python web application project structure with clear separation of concerns (app, routes, static, templates).
2. Set up a virtual environment and managed dependencies using requirements.txt.
3. Implemented the core application logic in app.py and configured the app with config.py.
4. Created database models in models.py and set up a local SQLite database for development.
5. Developed utility functions in utils.py and connection helpers in get_conn.py.
6. Organized API endpoints and main routes in the routes/ directory for modularity.
7. Built user-facing HTML templates in the templates/ folder and styled them with static/style.css.
8. Added a WSGI entry point (wsgi.py) to support deployment on production servers.
9. Documented the architecture and AI-related features in the docs directory.
10. Integrated infrastructure as code using Terraform scripts in the terraform folder.
11. Configured Azure Front Door and other cloud resources via Terraform for scalable deployment.
12. Managed environment-specific settings and local database files in the instance/ directory.
13. Maintained a clear and informative README.md for onboarding and usage instructions.
14. Used Git for version control and pushed changes to a remote repository.
16. Iteratively tested, debugged, and improved the application and infrastructure based on feedback and requirements.

## Order of flow

<img width="332" height="733" alt="image" src="https://github.com/user-attachments/assets/5c348681-5152-478a-8027-e8d1cb7533c1" />
