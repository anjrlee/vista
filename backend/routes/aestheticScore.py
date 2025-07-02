from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import PlainTextResponse
from fastapi import APIRouter


router = APIRouter()

# 劉威佑
@router.post("/aestheticScoreFunction")
async def aestheticScoreFunction(
    image: UploadFile = File(...),
    line_index: int = Form(...)
):
    image_bytes = await image.read()
    print(f"line_index: {line_index}, image bytes length: {len(image_bytes)}")


    return PlainTextResponse("6.8")
