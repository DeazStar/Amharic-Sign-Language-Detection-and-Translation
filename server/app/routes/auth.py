from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from app.config import settings
from app.utils.helpers import create_access_token

router = APIRouter()

@router.post("/admin/login")
def admin_login(form_data: OAuth2PasswordRequestForm = Depends()):
    if (
        form_data.username != settings.ADMIN_USERNAME
        or form_data.password != settings.ADMIN_PASSWORD
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
        )

    access_token = create_access_token(data={"sub": form_data.username})
    return {"access_token": access_token, "token_type": "bearer"}
