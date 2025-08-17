
from PIL import Image
import base64
import io
import os


import io
import base64
from PIL import Image

def poseDetection(image):

    img = Image.open("./assets/test.png")
    buffered = io.BytesIO()
    img.save(buffered, format="PNG")  # 保留透明背景
    img_bytes = buffered.getvalue()
    img_base64 = base64.b64encode(img_bytes).decode("utf-8")

    return img_base64
