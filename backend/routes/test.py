from fastapi import APIRouter
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv
import os
from pathlib import Path
router = APIRouter()

@router.get("/test")
def test():
    return {"message": "Hello FastAPI!"}






