from dotenv import load_dotenv
import os

load_dotenv()

STATIC_SIGN_PATH = os.getenv("STATIC_SIGN_PATH")
DYNAMIC_SIGN_PATH = os.getenv("DYNAMIC_SIGN_PATH")
STATIC_CSV_OUTPUT = os.getenv("STATIC_CSV_OUTPUT")
DYNAMIC_CSV_OUTPUT = os.getenv("DYNAMIC_CSV_OUTPUT")
STATIC_LABEL_PATH = os.getenv("STATIC_LABEL_PATH")
DYNAMIC_LABEL_PATH = os.getenv("DYNAMIC_LABEL_PATH")