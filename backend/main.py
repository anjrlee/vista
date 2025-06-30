from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import firebase_admin
from firebase_admin import credentials, firestore
import os
from pathlib import Path
from dotenv import load_dotenv


from routes import hello, test,composition  # 匯入剛剛寫的路由模組

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 或改成你的 Flutter 網址
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)






# 將路由器註冊到主應用
app.include_router(hello.router)
app.include_router(test.router)
app.include_router(composition.router)
