from fastapi import APIRouter
from fastapi import FastAPI, UploadFile, File
import binascii
import os
import platform
import subprocess
import base64
from services.remove_portrait import removePortrait
from services.pose_detection import poseDetection
from PIL import Image
import io
from dotenv import load_dotenv

router = APIRouter()
load_dotenv()


def open_image(filepath: str):
    system_name = platform.system()
    if system_name == "Darwin":  # macOS
        subprocess.run(["open", filepath])
    elif system_name == "Windows":  # Windows
        os.startfile(filepath)
    else:  # Linux and others
        subprocess.run(["xdg-open", filepath])

@router.post("/poseDetectionFunction")
async def poseDetectionFunction(image: UploadFile = File(...)):
    image_bytes = await image.read()
    print("Received image of size:", len(image_bytes), "bytes")
    img = Image.open(io.BytesIO(image_bytes))
    img_corrected = img.rotate(90, expand=True)

    buf = io.BytesIO()
    img_corrected.save(buf, format='JPEG')  # 一定要先寫入
    image_bytes = buf.getvalue()             # 再讀出 bytes

    image_bytes= removePortrait(image_bytes)
    # try:
    #     Image.open(io.BytesIO(image_bytes))
    # except Exception as e:
    #     print("removePortrait output is invalid:", e)
    #     return {"error": "removePortrait output is not a valid image"}

    pose_image=poseDetection(image_bytes)
    # try:
    #     Image.open(io.BytesIO(pose_image))
    # except Exception as e:
    #     print("poseDetection output is invalid:", e)
    #     return {"error": "poseDetection output is not a valid image"}

    # pose_b64 = base64.b64encode(pose_image).decode('utf-8')

    return {"poseIMG": pose_image}