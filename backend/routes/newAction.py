from fastapi import APIRouter, UploadFile, File
from fastapi.responses import StreamingResponse
from io import BytesIO
from services.generate_action import generate_action_image
from PIL import Image
import io

router = APIRouter()



@router.post("/analyzePose")
async def analyze_pose(image: UploadFile = File(...)):
    image_bytes = await image.read()
    pil_image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    heart_img = generate_action_image(pil_image)
    return StreamingResponse(heart_img, media_type="image/jpeg")

