import torch
import torch.nn as nn
import timm
import numpy as np
from PIL import Image
import albumentations as A
from albumentations.pytorch import ToTensorV2
import os
import json

# ==================== 配置參數 ====================
class PredictConfig:
    MODEL_NAME = 'swin_tiny_patch4_window7_224'
    IMG_SIZE = 224
    THRESHOLD = 0.5
    DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

# ==================== 模型定義 ====================
class SwinTransformerMultiLabel(nn.Module):
    def __init__(self, num_classes, model_name='swin_tiny_patch4_window7_224', pretrained=True):
        super(SwinTransformerMultiLabel, self).__init__()

        # 使用 timm 載入 Swin Transformer
        self.backbone = timm.create_model(
            model_name,
            pretrained=pretrained,
            num_classes=0  # 移除分類頭
        )

        # 獲取特徵維度
        self.feature_dim = self.backbone.num_features

        # 自定義分類頭
        self.classifier = nn.Linear(self.feature_dim, num_classes)
        self.sigmoid = nn.Sigmoid()

    def forward(self, x):
        features = self.backbone(x)
        logits = self.classifier(features)
        return logits

    def predict(self, x):
        logits = self.forward(x)
        return self.sigmoid(logits)

# ==================== 預處理函數 ====================
def get_predict_transform(img_size=224):
    """預測時的圖像預處理"""
    transform = A.Compose([
        A.Resize(img_size, img_size),
        A.Normalize(
            mean=[0.485, 0.456, 0.406],
            std=[0.229, 0.224, 0.225]
        ),
        ToTensorV2()
    ])
    return transform

# ==================== 模型載入函數 ====================
def load_model(model_path, classes, config):
    """載入訓練好的模型"""
    num_classes = len(classes)

    # 創建模型
    model = SwinTransformerMultiLabel(
        num_classes=num_classes,
        model_name=config.MODEL_NAME,
        pretrained=False  # 載入時不需要預訓練權重
    )

    # 載入模型權重
    model.load_state_dict(torch.load(model_path, map_location=config.DEVICE))
    model.to(config.DEVICE)
    model.eval()

    return model

# ==================== 單張圖片預測函數 ====================
def predict_single_image(image_path, model, classes, config, return_probabilities=False):
    """
    預測單張圖片

    Args:
        image_path: 圖片路徑
        model: 載入的模型
        classes: 類別列表
        config: 配置參數
        return_probabilities: 是否返回概率值

    Returns:
        dict: 預測結果
    """
    # 載入並預處理圖片
    try:
        image = Image.open(image_path).convert('RGB')
    except Exception as e:
        print(f"Error loading image {image_path}: {e}")
        return None

    # 圖像預處理
    transform = get_predict_transform(config.IMG_SIZE)
    image_np = np.array(image)
    transformed = transform(image=image_np)
    image_tensor = transformed['image'].unsqueeze(0)  # 添加 batch 維度

    # 移動到設備
    image_tensor = image_tensor.to(config.DEVICE)

    # 預測
    with torch.no_grad():
        outputs = model(image_tensor)
        probabilities = torch.sigmoid(outputs).cpu().numpy()[0]  # 移除 batch 維度
        predictions = (probabilities > config.THRESHOLD).astype(int)

    # 整理結果
    results = {
        'image_path': image_path,
        'predictions': {},
        'predicted_classes': []
    }

    for i, class_name in enumerate(classes):
        prob = float(probabilities[i])
        pred = bool(predictions[i])

        results['predictions'][class_name] = {
            'probability': prob,
            'predicted': pred
        }

        if pred:
            results['predicted_classes'].append(class_name)

    # 如果需要返回概率值
    if return_probabilities:
        results['all_probabilities'] = probabilities.tolist()

    return results

# ==================== 批量預測函數 ====================
def predict_batch_images(image_paths, model, classes, config, batch_size=16):
    """
    批量預測多張圖片

    Args:
        image_paths: 圖片路徑列表
        model: 載入的模型
        classes: 類別列表
        config: 配置參數
        batch_size: 批次大小

    Returns:
        list: 每張圖片的預測結果
    """
    all_results = []
    transform = get_predict_transform(config.IMG_SIZE)

    # 分批處理
    for i in range(0, len(image_paths), batch_size):
        batch_paths = image_paths[i:i+batch_size]
        batch_images = []
        valid_paths = []

        # 載入並預處理批次圖片
        for image_path in batch_paths:
            try:
                image = Image.open(image_path).convert('RGB')
                image_np = np.array(image)
                transformed = transform(image=image_np)
                batch_images.append(transformed['image'])
                valid_paths.append(image_path)
            except Exception as e:
                print(f"Error loading image {image_path}: {e}")
                continue

        if not batch_images:
            continue

        # 創建批次張量
        batch_tensor = torch.stack(batch_images).to(config.DEVICE)

        # 批次預測
        with torch.no_grad():
            outputs = model(batch_tensor)
            probabilities = torch.sigmoid(outputs).cpu().numpy()
            predictions = (probabilities > config.THRESHOLD).astype(int)

        # 整理批次結果
        for j, image_path in enumerate(valid_paths):
            results = {
                'image_path': image_path,
                'predictions': {},
                'predicted_classes': []
            }

            for k, class_name in enumerate(classes):
                prob = float(probabilities[j, k])
                pred = bool(predictions[j, k])

                results['predictions'][class_name] = {
                    'probability': prob,
                    'predicted': pred
                }

                if pred:
                    results['predicted_classes'].append(class_name)

            all_results.append(results)

    return all_results

# ==================== 使用範例 ====================
def main():
    """使用範例"""
    # 配置
    config = PredictConfig()

    # 定義類別（需要與訓練時相同）
    classes = ['cat', 'dog', 'bird', 'animal', 'flying']  # 替換為你的實際類別

    # 模型路徑
    model_path = './models/best_model_fold_0.pth'  # 替換為你的模型路徑

    # 載入模型
    print("Loading model...")
    model = load_model(model_path, classes, config)
    print("Model loaded successfully!")

    # 單張圖片預測
    image_path = 'path/to/your/image.jpg'  # 替換為你的圖片路徑

    if os.path.exists(image_path):
        print(f"\nPredicting image: {image_path}")

        # 標準多標籤預測
        result = predict_single_image(image_path, model, classes, config, return_probabilities=True)
        if result:
            print(f"Predicted classes (threshold={config.THRESHOLD}): {result['predicted_classes']}")
            print("\nDetailed results:")
            for class_name, pred_info in result['predictions'].items():
                print(f"  {class_name}: {pred_info['probability']:.3f} ({'✓' if pred_info['predicted'] else '✗'})")

        # 最高概率預測
        print(f"\n" + "="*50)
        print("HIGHEST PROBABILITY PREDICTION")
        print("="*50)

        # Top 1 最高概率
        top1_result = highest_possibility_predict(image_path, model, classes, config, top_k=1)
        if top1_result:
            print(f"Most likely class: {top1_result[0]['class']} (probability: {top1_result[0]['probability']:.3f})")

        # Top 3 最高概率
        top3_results = highest_possibility_predict(image_path, model, classes, config, top_k=3)
        if top3_results:
            print(f"\nTop 3 most likely classes:")
            for i, result in enumerate(top3_results, 1):
                print(f"  {i}. {result['class']}: {result['probability']:.3f}")

        # 使用簡化函數
        print(f"\n" + "="*50)
        print("USING SIMPLIFIED FUNCTIONS")
        print("="*50)

        # 簡化的最高概率預測
        simple_top1 = simple_highest_predict(image_path, model_path, classes, top_k=1)
        if simple_top1:
            print(f"Simple highest predict: {simple_top1[0]['class']} ({simple_top1[0]['probability']:.3f})")

        # 簡化的多標籤預測
        simple_multi = simple_predict(image_path, model_path, classes, threshold=0.5)
        print(f"Simple multi-label predict: {simple_multi}")
    else:
        print(f"Image not found: {image_path}")

    # 批量預測範例
    image_folder = 'path/to/your/images/'  # 替換為你的圖片資料夾
    if os.path.exists(image_folder):
        image_paths = [
            os.path.join(image_folder, f)
            for f in os.listdir(image_folder)
            if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))
        ]

        if image_paths:
            print(f"\nBatch predicting {len(image_paths)} images...")
            batch_results = predict_batch_images(image_paths, model, classes, config)

            print("Batch prediction completed!")
            for result in batch_results[:3]:  # 只顯示前3個結果
                print(f"  {os.path.basename(result['image_path'])}: {result['predicted_classes']}")

            # 批量最高概率預測
            print(f"\nBatch highest probability predictions:")
            for image_path in image_paths[:3]:  # 只處理前3張圖片
                top1 = simple_highest_predict(image_path, model_path, classes, top_k=1)
                if top1:
                    print(f"  {os.path.basename(image_path)}: {top1[0]['class']} ({top1[0]['probability']:.3f})")

# ==================== 最高概率預測函數 ====================
def highest_possibility_predict(image_path, model, classes, config, top_k=2):
    """
    預測最高概率的類別

    Args:
        image_path: 圖片路徑
        model: 載入的模型
        classes: 類別列表
        config: 配置參數
        top_k: 返回前 k 個最高概率的類別

    Returns:
        list: 包含類別名稱和概率的字典列表，按概率降序排列
    """
    # 載入並預處理圖片
    try:
        image = Image.open(image_path).convert('RGB')
    except Exception as e:
        print(f"Error loading image {image_path}: {e}")
        return None

    # 圖像預處理
    transform = get_predict_transform(config.IMG_SIZE)
    image_np = np.array(image)
    transformed = transform(image=image_np)
    image_tensor = transformed['image'].unsqueeze(0)  # 添加 batch 維度

    # 移動到設備
    image_tensor = image_tensor.to(config.DEVICE)

    # 預測
    with torch.no_grad():
        outputs = model(image_tensor)
        probabilities = torch.sigmoid(outputs).cpu().numpy()[0]  # 移除 batch 維度

    # 創建類別-概率對應關係
    class_probs = []
    for i, class_name in enumerate(classes):
        class_probs.append({
            'class': class_name,
            'probability': float(probabilities[i])
        })

    # 按概率降序排列
    class_probs.sort(key=lambda x: x['probability'], reverse=True)

    # 返回前 top_k 個結果
    return class_probs[:top_k]

def simple_highest_predict(image_path, model_path, classes=["horizontal","vertical","center","diagonal", "rule_of_thirds", "symmetric", "triangle" ], top_k=1):
    """
    簡化的最高概率預測函數

    Args:
        image_path: 圖片路徑
        model_path: 模型路徑
        classes: 類別列表
        top_k: 返回前 k 個最高概率的類別

    Returns:
        list: 最高概率的類別信息
    """
    config = PredictConfig()

    # 載入模型
    model = load_model(model_path, classes, config)

    # 預測
    result = highest_possibility_predict(image_path, model, classes, config, top_k)
    print("test")
    print(result)
    return result

# ==================== 簡化的預測函數 ====================
def simple_predict(image_path, model_path, classes, threshold=0.5):
    """
    簡化的預測函數，適合快速使用

    Args:
        image_path: 圖片路徑
        model_path: 模型路徑
        classes: 類別列表
        threshold: 預測閾值

    Returns:
        list: 預測的類別列表
    """
    config = PredictConfig()
    config.THRESHOLD = threshold

    # 載入模型
    model = load_model(model_path, classes, config)

    # 預測
    result = predict_single_image(image_path, model, classes, config)

    return result['predicted_classes'] if result else []

