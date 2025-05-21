from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.database import SessionLocal
from app.schemas.feedback import FeedbackCreate, FeedbackOut
from app.crud import feedback as crud_feedback
from app.core.security import get_admin

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/post-feedback", response_model=FeedbackOut)
def post_feedback(feedback: FeedbackCreate, db: Session = Depends(get_db)):
    return crud_feedback.create_feedback(db, feedback)

@router.get("/get-feedbacks", response_model=list[FeedbackOut])
def get_feedbacks(db: Session = Depends(get_db), _: str = Depends(get_admin)):
    return crud_feedback.get_unresolved_feedbacks(db)
