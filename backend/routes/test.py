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






load_dotenv()
cred_path = os.getenv("FIREBASE_CREDENTIAL_PATH")
if not cred_path:
    raise ValueError("FIREBASE_CREDENTIAL_PATH 沒有設定")

cred = credentials.Certificate(cred_path)
firebase_admin.initialize_app(cred)


db = firestore.client()

@router.post("/testFirebase")
def test():
    now = datetime.now().isoformat()
    doc_ref = db.collection("test_collection").document()  # 自動產生id的document

    data = {
        "timestamp": now
    }

    doc_ref.set(data)  # 寫入 Firestore

    return {"message": "寫入成功", "datetime": now}

