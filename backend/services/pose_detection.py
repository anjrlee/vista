import torch
import torchvision.transforms as transforms
from PIL import Image
import numpy as np
import base64
import io
import os
import random

IMG_H, IMG_W = 640, 360
SCALE_BOOST = 1.1

ASSETS_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets')
MODEL_PATH = os.path.join(ASSETS_DIR, "position.pt")
POSE_BLACK_DIR = os.path.join(ASSETS_DIR, "poses", "black")
POSE_WHITE_DIR = os.path.join(ASSETS_DIR, "poses", "white")

predictor = None

class PosePredictor:
    def __init__(self, model_path, pose_black_dir, pose_white_dir):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        print(f"PosePredictor 使用裝置: {self.device}")
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"找不到模型檔案: {model_path}")
        
        self.model = torch.jit.load(model_path, map_location=self.device)
        self.model.eval()

        self.black_poses = self._load_pose_paths(pose_black_dir)
        self.white_poses = self._load_pose_paths(pose_white_dir)
        
        if not self.black_poses and not self.white_poses:
            raise FileNotFoundError(f"在 {pose_black_dir} 和 {pose_white_dir} 中都找不到任何 .png 姿勢圖檔")

    def _load_pose_paths(self, folder):
        if not os.path.isdir(folder):
            print(f"找不到姿勢資料夾: {folder}")
            return []
        return [os.path.join(folder, f) for f in os.listdir(folder) if f.lower().endswith(".png")]

    def _letterbox(self, image: Image.Image):
        w, h = image.size
        scale = min(IMG_W / w, IMG_H / h)
        nw, nh = int(w * scale), int(h * scale)
        
        resized_image = image.resize((nw, nh), Image.BILINEAR)
        
        new_image = Image.new("RGB", (IMG_W, IMG_H), (0, 0, 0))
        pad_x = (IMG_W - nw) // 2
        pad_y = (IMG_H - nh) // 2
        new_image.paste(resized_image, (pad_x, pad_y))
        
        return new_image, scale, pad_x, pad_y

    def _recover_to_original(self, px, py, pw, ph, scale, pad_x, pad_y):
        ox = (px - pad_x) / max(1e-9, scale)
        oy = (py - pad_y) / max(1e-9, scale)
        ow = pw / max(1e-9, scale)
        oh = ph / max(1e-9, scale)
        return ox, oy, ow, oh

    def _choose_pose_path(self, background_pil, x, y, w, h):
        x0, y0 = max(0, int(x)), max(0, int(y))
        x1, y1 = max(x0 + 1, int(x + w)), max(y0 + 1, int(y + h))
        
        crop = background_pil.crop((x0, y0, x1, y1))
        if crop.size[0] == 0 or crop.size[1] == 0:
            return random.choice(self.white_poses) if self.white_poses else None

        gray_crop = np.array(crop.convert("L"))
        brightness = np.quantile(gray_crop, 0.30)
        if brightness < 147:
            return random.choice(self.white_poses) if self.white_poses else random.choice(self.black_poses)
        else:
            return random.choice(self.black_poses) if self.black_poses else random.choice(self.white_poses)

    def predict(self, image_pil: Image.Image) -> Image.Image:

        orig_w, orig_h = image_pil.size

        lb_img, scale, pad_x, pad_y = self._letterbox(image_pil)
        to_tensor = transforms.ToTensor()
        tensor_img = to_tensor(lb_img).unsqueeze(0).to(self.device)

        with torch.no_grad():
            pred = self.model(tensor_img).squeeze(0).cpu().numpy()

        lx, ly, lw, lh = pred[0]*IMG_W, pred[1]*IMG_H, pred[2]*IMG_W, pred[3]*IMG_H
        ox, oy, ow, oh = self._recover_to_original(lx, ly, lw, lh, scale, pad_x, pad_y)

        pose_path = self._choose_pose_path(image_pil, ox, oy, ow, oh)
        if not pose_path:
            return Image.new("RGBA", (orig_w, orig_h), (0, 0, 0, 0))

        pose_img = Image.open(pose_path).convert("RGBA")
    
        canvas = Image.new("RGBA", (orig_w, orig_h), (0, 0, 0, 0))

        pw, ph = pose_img.size
        ratio = min(ow / pw, oh / ph) * SCALE_BOOST
        new_size = (max(1, int(pw * ratio)), max(1, int(ph * ratio)))
        pose_resized = pose_img.resize(new_size, Image.Resampling.LANCZOS)
        
        paste_x = int(ox + (ow - new_size[0]) // 2)
        paste_y = int(oy + (oh - new_size[1]) // 2)
   
        canvas.paste(pose_resized, (paste_x, paste_y), pose_resized)
        
        return canvas

def poseDetection(image_str: str) -> str:

    global predictor

    if predictor is None:
        try:
            predictor = PosePredictor(MODEL_PATH, POSE_BLACK_DIR, POSE_WHITE_DIR)
        except FileNotFoundError as e:
            print(f"初始化錯誤: {e}")
            return ""

    try:
        image_bytes = base64.b64decode(image_str)
        image_pil = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    except Exception as e:
        print(f"無法讀取圖片 bytes: {e}")
        return ""

    result_pil = predictor.predict(image_pil)

    buffered = io.BytesIO()
    result_pil.save(buffered, format="PNG")
    img_bytes = buffered.getvalue()
    img_base64 = base64.b64encode(img_bytes).decode("utf-8")

    return img_base64