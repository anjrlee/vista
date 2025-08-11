from PIL import Image
from io import BytesIO
import cv2
import numpy as np
from ultralytics import YOLO

model = YOLO('yolov8n-seg.pt')  # 你初始化一次即可

def generate_action_image(image):
    # 1. 判斷 image 類型，轉成 OpenCV BGR np.ndarray
    if isinstance(image, Image.Image):
        img_cv = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)
    elif isinstance(image, bytes):
        img_cv = cv2.imdecode(np.frombuffer(image, np.uint8), cv2.IMREAD_COLOR)
    elif isinstance(image, str):
        img_cv = cv2.imread(image)
    elif isinstance(image, np.ndarray):
        # 假如前端直接送了 numpy 陣列，直接用
        img_cv = image
    else:
        raise ValueError(f"Unsupported image type: {type(image)}")

    # 2. YOLO segmentation
    results = model(img_cv)[0]

    mask = np.zeros(img_cv.shape[:2], dtype=np.uint8)
    if results.masks is not None:
        for i, seg in enumerate(results.masks.xy):
            cls_id = int(results.boxes.cls[i])
            if cls_id == 0:  # person 類別
                pts = np.array(seg, dtype=np.int32)
                cv2.fillPoly(mask, [pts], 255)

    # 3. 只保留人像區域
    masked_img = cv2.bitwise_and(img_cv, img_cv, mask=mask)

    # 4. Canny 邊緣 + 模糊
    gray = cv2.cvtColor(masked_img, cv2.COLOR_BGR2GRAY)
    edges = cv2.Canny(gray, 150, 200)
    blurred_edges = cv2.GaussianBlur(edges, (5, 5), 1)

    # 5. 反相 (白底黑線 → 黑底白線)
    inverted = cv2.bitwise_not(blurred_edges)

    # 6. 轉 BytesIO (JPEG 格式)
    buf = BytesIO()
    Image.fromarray(inverted).save(buf, format="JPEG")
    buf.seek(0)
    return buf
