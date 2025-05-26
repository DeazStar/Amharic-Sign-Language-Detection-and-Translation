from sqlalchemy.orm import Session
from app.db import models
from app.schemas.feedback import FeedbackCreate

def create_feedback(db: Session, feedback: FeedbackCreate):
    db_feedback = models.Feedback(message=feedback.message)
    db.add(db_feedback)
    db.commit()
    db.refresh(db_feedback)
    return db_feedback

def get_unresolved_feedbacks(db: Session):
    return db.query(models.Feedback).filter(models.Feedback.resolved == False).order_by(models.Feedback.timestamp.desc()).all()

def mark_feedback_as_resolved(db: Session, feedback_id: int):
    feedback = db.query(models.Feedback).filter(models.Feedback.id == feedback_id).first()
    if feedback:
        feedback.resolved = True
        db.commit()
    return feedback
