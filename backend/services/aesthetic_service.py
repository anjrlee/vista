import os
import io
import numpy as np
from PIL import Image
import tensorflow as tf
from tensorflow.keras.applications import NASNetMobile
from tensorflow.keras.layers import Dense, Dropout
from tensorflow.keras.models import Model
from nasnet_utils.score_utils import mean_score, std_score

# 載入模型（只載一次）
with tf.device('/CPU:0'):
    base_model = NASNetMobile(input_shape=(224, 224, 3), include_top=False, pooling='avg', weights=None)
    x = Dropout(0.75)(base_model.output)
    x = Dense(10, activation='softmax')(x)
    model = Model(base_model.input, x)
    model_path = os.getenv("AESTHETIC_MODEL")
    model.load_weights(model_path)

def calculate_aesthetic_score(image_bytes: bytes) -> float:
    img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
    img = img.resize((224, 224), Image.LANCZOS)

    x = np.array(img)
    x = np.expand_dims(x, axis=0)
    x = tf.keras.applications.mobilenet.preprocess_input(x)

    scores = model.predict(x, batch_size=1, verbose=0)[0]

    mean = mean_score(scores)
    # std = std_score(scores)
    print(f"Aesthetic mean score: {mean:.4f}")
    return mean
