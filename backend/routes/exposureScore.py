from fastapi import APIRouter, File, UploadFile, Form
from fastapi.responses import PlainTextResponse
import os, shutil

from services.exposure_service import ExposureService

router = APIRouter()
exposure_service = ExposureService()  # 啟動時就載入模型，只初始化一次

@router.post("/exposureScoreFunction")
async def exposure_score_function(
    image: UploadFile = File(...),
    exposure_value: float = Form(...)
):
    """
    曝光評分 API
    - 上傳一張圖片 (image)
    - 傳入一個 exposure_value (float)
    - 回傳模型的曝光分數（純文字）
    """
    # 暫存檔案
    temp_path = f"temp_{image.filename}"
    with open(temp_path, "wb") as buffer:
        shutil.copyfileobj(image.file, buffer)

    try:
        # 呼叫 service 推論
        score = exposure_service.predict_score(temp_path)
        print(f"[DEBUG] 收到 exposure_value={exposure_value}, 預測 score={score}")
        return PlainTextResponse(f"{score:.1f}")  # 回傳單純文字，方便前端使用
    finally:
        # 清理暫存檔
        if os.path.exists(temp_path):
            os.remove(temp_path)
