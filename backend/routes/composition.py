from fastapi import APIRouter
from fastapi import FastAPI, UploadFile, File
import binascii
import os
import platform
import subprocess
from services.composition_detect import simple_highest_predict
from services.remove_portrait import removePortrait
from dotenv import load_dotenv
import tempfile
from PIL import Image
import io


router = APIRouter()



def open_image(filepath: str):
    system_name = platform.system()
    if system_name == "Darwin":  # macOS
        subprocess.run(["open", filepath])
    elif system_name == "Windows":  # Windows
        os.startfile(filepath)
    else:  # Linux and others
        subprocess.run(["xdg-open", filepath])

@router.post("/compositionDetection")
async def compositionDetection(image: UploadFile = File(...)):
    image_bytes = await image.read()
    img = Image.open(io.BytesIO(image_bytes))
    img_corrected = img.rotate(90, expand=True)

    buf = io.BytesIO()
    img_corrected.save(buf, format='JPEG')  # 一定要先寫入
    image_bytes = buf.getvalue()             # 再讀出 bytes

    image_bytes= removePortrait(image_bytes)

    with tempfile.NamedTemporaryFile(delete=False, suffix=".jpg") as temp_image:
        temp_image.write(image_bytes)
        temp_image_path = temp_image.name


    load_dotenv()

    model_path = os.getenv("COMPOSITION_DETECT_MODEL")
    if not model_path:
        raise ValueError("COMPOSITION_DETECT_MODEL not found in .env")


    top1 = simple_highest_predict(temp_image_path, model_path)

    print(top1[0]['class'])
    if top1:
        return {"composition": top1[0]['class']}
    else:
        return {"error": "Prediction failed"}





@router.get("/filterAlbum")
def testComposition():
    return {"composition": function1()}

@router.post("/testComposition")
def testComposition():
    return {"composition": function1()}



