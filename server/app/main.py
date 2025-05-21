from fastapi import FastAPI
from app.routes import image_processing

app = FastAPI(title="Hand Detection API")

# Include image processing routes
app.include_router(image_processing.router)