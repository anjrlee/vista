from fastapi import APIRouter, UploadFile, File
from fastapi.responses import StreamingResponse
from io import BytesIO
from services.generate_action import generate_action_image

router = APIRouter()



@router.post("/analyzePose")
async def analyze_pose(image: UploadFile = File(...)):
    heart_img = generate_action_image(image)
    return StreamingResponse(heart_img, media_type="image/jpeg")

