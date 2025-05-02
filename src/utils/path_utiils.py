from urllib.parse import urlparse
import requests
import os 

def is_remote_path(path):
    parsed = urlparse(path)
    return parsed.scheme in ("http", "https", "s3", "ftp")

def file_exists(path):
    if is_remote_path(path):
        try:
            response = requests.head(path)
            return response.status_code == 200
        except requests.RequestException:
            return False
    else:
        return os.path.exists(path)