from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# 👇 加上 CORS 讓 Flutter 可以連線（注意設定 origin）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 或改成你的 Flutter 網址
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/hello")
def say_hello():
    return {"message": "Hello from FastAPI!"}

@app.post("/echo")
def echo_data(data: dict):
    return {"you_sent": data}
