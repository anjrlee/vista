import cv2
import numpy as np
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt

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
    original = cv2.imread(image_path)

    crop_percentage = [0, 0.05, 0.10, 0.15]
    images = [crop_border(original, i) for i in crop_percentage]


    scores = [calculate_color_clutter_from_image(img) for img in images]
    best_idx = np.argmin(scores)

    # 顯示三張圖 + 分數 + 用紅框標出最佳

    return crop_percentage[best_idx]



