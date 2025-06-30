from fastapi import APIRouter

router = APIRouter()

@router.post("/hello")
def say_hello():
    return {"message": "Hello from FastAPI!"}

@router.post("/echo")
def echo_data(data: dict):
    return {"you_sent": data}
