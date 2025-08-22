import os
import torch
import importlib.util
from dotenv import load_dotenv
from torchvision import transforms
from PIL import Image

# 載入 .env
load_dotenv()

class ExposureService:
    def __init__(self, model_path=None, wavelet_network_path=None, device=None):
        self.device = device or torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

        # 讀取 .env 的環境變數
        model_path = model_path or os.getenv("EXPOSURE_MODEL", "./model/exposure.pth")
        wavelet_network_path = wavelet_network_path or os.getenv("WAVELET_NETWORK", "./model/wavelet_network.py")

        # 動態載入 wavelet_network.py
        if not os.path.exists(wavelet_network_path):
            raise FileNotFoundError(f"找不到模型定義檔案: {wavelet_network_path}")

        spec = importlib.util.spec_from_file_location("wavelet_network", wavelet_network_path)
        wavelet_module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(wavelet_module)

        # 初始化模型
        self.model = wavelet_module.Wavelet_Net()

        if not os.path.exists(model_path):
            raise FileNotFoundError(f"找不到模型權重檔: {model_path}")

        self.model.load_state_dict(torch.load(model_path, map_location=self.device))
        self.model = self.model.to(self.device).eval()

        # 圖片轉換流程
        self.transform = transforms.Compose([
            transforms.Resize((256, 256)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0., 0., 0.], std=[1., 1., 1.])
        ])

    def read_image(self, image_path):
        return Image.open(image_path).convert("RGB")

    def predict_score(self, image_path: str) -> float:
        """單張圖片曝光分數預測"""
        image = self.read_image(image_path)
        tensor = self.transform(image).unsqueeze(0).to(self.device)

        with torch.no_grad():
            score = self.model(tensor)

        return float(score.cpu().numpy().item())

