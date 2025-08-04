from fastapi import APIRouter, Depends, HTTPException
from auth import get_current_user  # If auth.py is in the same backend folder

router = APIRouter()

@router.get("/protected")
def protected_route(current_user=Depends(get_current_user)):
    return {"message": "Hello, secure world!", "user": current_user["email"]}
