import os
from fastapi import FastAPI, UploadFile, File, Form, APIRouter
from fastapi.responses import PlainTextResponse
import numpy as np
from PIL import Image
import io
import tensorflow as tf
from tensorflow.keras.applications import NASNetMobile
from tensorflow.keras.layers import Dense, Dropout
from tensorflow.keras.models import Model
from nasnet_utils.score_utils import mean_score, std_score  # Assumes these functions are defined in nasnet_utils.score_utils
import os

router = APIRouter()

# Load the NIMA model once at startup
with tf.device('/CPU:0'):
    base_model = NASNetMobile(input_shape=(224, 224, 3), include_top=False, pooling='avg', weights=None)
    x = Dropout(0.75)(base_model.output)
    x = Dense(10, activation='softmax')(x)
    model = Model(base_model.input, x)
    model_path = os.getenv("AESTHETIC_MODEL")
    model.load_weights(model_path)  # Ensure the path to the weights file is correct

@router.post("/aestheticScoreFunction")
async def aestheticScoreFunction(
    image: UploadFile = File(...),
    line_index: int = Form(...)
):
    # Read image bytes
    image_bytes = await image.read()
    print(f"line_index: {line_index}, image bytes length: {len(image_bytes)}")

    # Convert bytes to PIL image and preprocess
    img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
    img = img.resize((224, 224), Image.LANCZOS)
    
    # Convert to numpy array and expand dimensions
    x = np.array(img)
    x = np.expand_dims(x, axis=0)

    # Preprocess image for the model
    x = tf.keras.applications.mobilenet.preprocess_input(x)

    # Perform model inference
    scores = model.predict(x, batch_size=1, verbose=0)[0]

    # Calculate mean and standard deviation of aesthetic scores
    mean = mean_score(scores)
    std = std_score(scores)

    # Return the result as a formatted string
    return PlainTextResponse(f"{mean:.3f} ± {std:.3f}")