from pydantic import BaseModel
from datetime import datetime

class FeedbackCreate(BaseModel):
    message: str

class FeedbackOut(BaseModel):
    id: int
    message: str
    resolved: bool
    timestamp: datetime

    class Config:
        orm_mode = True
