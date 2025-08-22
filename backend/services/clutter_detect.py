import cv2
import numpy as np
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt
from PIL import Image
import io
import base64

def calculate_color_clutter(image_path, k_range=(2, 10)):
    # 讀取圖像並轉為 HSV
    image = cv2.imread(image_path)
    image_hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    h, w, _ = image.shape
    pixels = image_hsv.reshape(-1, 3)

    # 忽略飽和度低的像素（例如灰、黑、白區）
    valid_pixels = pixels[pixels[:, 1] > 20]  # S > 20：排除低彩度
    if len(valid_pixels) < 100:
        print("圖片色彩太單一，無法分析雜亂度。")
        return 1

    # K-means 聚類
    k = k_range[1]  # 最大群數（雜亂度高）
    kmeans = KMeans(n_clusters=k, n_init='auto').fit(valid_pixels)
    labels, counts = np.unique(kmeans.labels_, return_counts=True)

    # 計算主色數（出現比例高於閾值）
    threshold = 0.08
    major_colors = sum(counts / sum(counts) > threshold)

    # 映射為 1~10 分制
    clutter_score = int(np.clip((major_colors / k) * 10, 1, 10))

    print(f"主色數量: {major_colors}, 雜亂度（1~10）: {clutter_score}")
    return clutter_score

# 範例用法

#print(calculate_color_clutter("post2.jpg"))




def calculate_color_clutter_from_image(image, k_range=(2, 10)):
    image_hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    pixels = image_hsv.reshape(-1, 3)
    valid_pixels = pixels[pixels[:, 1] > 20]  # 只看彩度夠的點
    if len(valid_pixels) < 100:
        return 1
    k = k_range[1]
    kmeans = KMeans(n_clusters=k, n_init='auto').fit(valid_pixels)
    labels, counts = np.unique(kmeans.labels_, return_counts=True)
    major_colors = sum(counts / sum(counts) > 0.08)
    clutter_score = int(np.clip((major_colors / k) * 10, 1, 10))
    return clutter_score

def crop_border(image, percent=0):
    h, w = image.shape[:2]
    dh, dw = int(h * percent), int(w * percent)
    return image[dh:h-dh, dw:w-dw]

def analyze_image_with_crops(image_path):
    # 讀圖
    original = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)

    crop_percentages = [0, 0.05, 0.10, 0.15, 0.2]
    images = [crop_border(original, i) for i in crop_percentages]

    scores = [calculate_color_clutter_from_image(img) for img in images]
    best_idx = np.argmin(scores)

    best_cropped = images[best_idx]

    # 將 numpy array 轉 PIL Image
    if best_cropped.shape[2] == 3:  # BGR → RGB
        best_cropped = cv2.cvtColor(best_cropped, cv2.COLOR_BGR2RGB)
    img_pil = Image.fromarray(best_cropped)

    # 轉成 PNG Base64
    buffered = io.BytesIO()
    img_pil.save(buffered, format="PNG")
    img_bytes = buffered.getvalue()
    img_base64 = base64.b64encode(img_bytes).decode("utf-8")

    return crop_percentages[best_idx], img_base64


