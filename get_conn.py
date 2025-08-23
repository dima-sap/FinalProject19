"""
Azure PostgreSQL connection helper with password authentication
"""
import urllib.parse
import os


def get_connection_uri():
    """
    Get Azure PostgreSQL connection URI with password authentication
    
    Required environment variables:
    - DBHOST: Azure PostgreSQL server name (e.g., myserver.postgres.database.azure.com)
    - DBNAME: Database name (e.g., postgres)
    - DBUSER: Database username (e.g., pgadminuser)
    - DBPASSWORD: Database password
    - SSLMODE: SSL mode (should be 'require' for Azure, optional)
    
    Returns:
        str: PostgreSQL connection URI
    """
    dbhost = os.environ.get('DBHOST')
    dbname = os.environ.get('DBNAME', 'postgres')
    dbuser = urllib.parse.quote(os.environ.get('DBUSER', ''))
    password = os.environ.get('DBPASSWORD')
    sslmode = os.environ.get('SSLMODE', 'require')
    
    if not all([dbhost, dbuser, password]):
        raise ValueError("DBHOST, DBUSER, and DBPASSWORD environment variables are required")
    
    db_uri = f"postgresql://{dbuser}:{password}@{dbhost}/{dbname}?sslmode={sslmode}"
    return db_uri
