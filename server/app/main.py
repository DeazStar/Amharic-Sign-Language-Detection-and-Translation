from fastapi import FastAPI
from app.db.database import engine
from app.db import models
from app.routes import image_processing , feedback, video_translation, auth

app = FastAPI(title="Hand Detection API")

# Include image processing routes
app.include_router(image_processing.router)
app.include_router(feedback.router)
app.include_router(video_translation.router, prefix="/api/video", tags=["Video Translation"])
app.include_router(auth.router)