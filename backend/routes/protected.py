# protected.py

from fastapi import APIRouter, Depends, HTTPException
from auth import get_current_user  # Adjust if your auth.py is in a different folder

router = APIRouter()

@router.get("/protected")
def protected_route(current_user=Depends(get_current_user)):
    return {"message": "Hello, secure world!", "user": current_user["email"]}
