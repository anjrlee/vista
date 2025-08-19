# 使用前記得加 clipdrop API key
import cv2
import numpy as np
import requests
import io
import os
from PIL import Image
import mediapipe as mp

class PortraitRemover:
    def __init__(self, api_key: str):
        if not api_key:
            raise ValueError("Clipdrop API 金鑰不可為空")
        self.api_key = api_key
        self.mp_selfie_segmentation = mp.solutions.selfie_segmentation
        self.selfie_segmentation = self.mp_selfie_segmentation.SelfieSegmentation(model_selection=0)

    def _generate_mask(self, image_bytes: bytes) -> np.ndarray:
        pil_image = Image.open(io.BytesIO(image_bytes))
        image_np = np.array(pil_image.convert('RGB'))
        results = self.selfie_segmentation.process(image_np)
        binary_mask = np.where(results.segmentation_mask > 0.1, 255, 0).astype(np.uint8)
        return binary_mask

    def _improve_mask(self, mask: np.ndarray, iterations: int = 5) -> np.ndarray:
        kernel = np.ones((5, 5), np.uint8)
        dilated_mask = cv2.dilate(mask, kernel, iterations=iterations)
        return dilated_mask

    def remove_portrait_from_bytes(self, image_bytes: bytes) -> bytes:
        initial_mask = self._generate_mask(image_bytes)
        improved_mask = self._improve_mask(initial_mask)

        success, mask_buffer = cv2.imencode(".png", improved_mask)
        if not success:
            print("錯誤：無法將遮罩編碼為 PNG 格式。")
            return image_bytes
        mask_bytes = mask_buffer.tobytes()

        files = {
            'image_file': ('original_image.png', image_bytes, 'image/png'),
            'mask_file': ('mask.png', mask_bytes, 'image/png')
        }
        headers = {'x-api-key': self.api_key}

        try:
            response = requests.post(
                'https://clipdrop-api.co/cleanup/v1',
                files=files,
                headers=headers
            )
            if response.ok:
                return response.content
            else:
                print(f"API 請求失敗: {response.status_code} - {response.text}")
                return image_bytes
        except requests.exceptions.RequestException as e:
            print(f"網路請求時發生錯誤: {e}")
            return image_bytes

def removePortrait(image_bytes: bytes) -> bytes:
    API_KEY = os.getenv("CLIPDROP_API_KEY", "YOUR_CLIPDROP_API_KEY")
    
    if API_KEY == "YOUR_CLIPDROP_API_KEY" or not API_KEY:
        print("請設定 CLIPDROP_API_KEY 環境變數，或直接在 remove_portrait.py 中填入 API key。")
        return image_bytes

    remover = PortraitRemover(api_key=API_KEY)
    return remover.remove_portrait_from_bytes(image_bytes)
